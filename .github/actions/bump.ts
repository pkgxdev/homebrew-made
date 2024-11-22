#!/usr/bin/env -S pkgx deno run --allow-net --allow-run --allow-read --allow-write --allow-env

import { backticks, run, panic } from "utils"
import { basename } from "deno/path/mod.ts"
import { crypto, toHashString } from "deno/crypto/mod.ts"

const rootUrl = "https://github.com/pkgxdev/homebrew-made/releases/download"

const livecheck: LCResults[] = await (async () => {
  if (Deno.args[0]) {
    const [current, latest] = Deno.args
    return [{
      formula: 'pkgx',
      version: {
        outdated: true,
        current, latest
      }
    }]
  } else {
    const tap = Deno.env.get("TAP") ?? panic("No TAP specified")
    return JSON.parse(await backticks({ cmd: [
      "brew", "livecheck", "--quiet", "--newer-only", "--full-name", "--json", `--tap=${tap}`
    ]}))
  }
})()
// const livecheck: LCResults[] = JSON.parse(await backticks({ cmd: ["brew", "livecheck", "--quiet", "--newer-only", "--full-name", "--json", `./pkgx.rb`] }))

if (livecheck.length === 0) {
  console.log("No outdated packages")
  Deno.exit(0)
}

if (Deno.env.get("GITHUB_ACTIONS")) {
  // Configure git
  await run({ cmd: ["git", "config", "user.name", "github-actions"] })
  await run({ cmd: ["git", "config", "user.email", "github-actions@github.com"] })
}

for (const pkg of livecheck) {
  if (pkg.version.outdated) {
    const oldVersion = pkg.version.current
    const newVersion = pkg.version.latest
    const name = basename(pkg.formula)
    const formula = await Deno.readTextFile(`${name}.rb`)

    const url = formula.match(/  url "(.*)"/)?.[1]
    const newUrl = url.replaceAll(oldVersion, newVersion)
    const newSha = await sha256(newUrl)

    const bottles = await bottle(newVersion)

    // Generate new bottle block.
    const newBottleBlock = generateBottleBlock(bottles, newVersion)

    const newFormula = formula.replaceAll(url, newUrl).replace(/  sha256 ".+"/, `  sha256 "${newSha}"`)
                              .replace(/bottle do[\s\S]*?end$/m, newBottleBlock)

    await Deno.writeTextFile(`${name}.rb`, newFormula)

    if (Deno.env.get("GITHUB_ACTIONS")) {
      await run({ cmd: ["git", "add", `${name}.rb`] })
      await run({ cmd: ["git", "commit", "-m", `bump ${name} from ${oldVersion} to ${newVersion}`] })

      const envFile = Deno.env.get("GITHUB_OUTPUT")!
      await Deno.writeTextFile(envFile, `name=${name}\nversion=${newVersion}\n`, { append: true})
    }

    console.log(`Bumped ${name} from ${oldVersion} to ${newVersion}`)
  }
}

interface LCResults {
  formula: string
  version: {
    current: string
    latest: string
    outdated: boolean
    newer_than_upstream: boolean
  }
}

async function sha256(url: string) {
  const file = await fetch(url).then(res => res.arrayBuffer())
  const hash = await crypto.subtle.digest("SHA-256", file)
  return toHashString(hash)
}

interface Bottle {
  platform: string
  sha256: string
  url: string
}

async function bottle(newVersion: string): Promise<Bottle[]> {
  await run({ cmd: ["mkdir", "-p", "bottles"] })
  const platforms = ["darwin+aarch64", "darwin+x86-64", "linux+x86-64"] // "linux+aarch64" not supported for bottles yet

  const bottles: Bottle[] = []

  for (const platform of platforms) {
    const bottleUrl = `https://github.com/pkgxdev/pkgx/releases/download/v${newVersion}/pkgx-${newVersion}+${platform}.tar.xz`
    const prefix = platform === "darwin+aarch64" ? "opt/homebrew" : "usr/local/Homebrew"

    // Download the tarball
    const response = await fetch(bottleUrl)
    const file = await response.arrayBuffer()

    // Convert ArrayBuffer to Uint8Array for Deno.writeFile
    const uint8Array = new Uint8Array(file)
    const binaryFileName = `pkgx-${newVersion}+${platform}.tar.xz`

    // Save the binary to a file
    await Deno.writeFile(binaryFileName, uint8Array)

        // Build the directory structure
    const cellarPath = `pkgx/${newVersion}`
    await run({ cmd: ["mkdir", "-p", `${cellarPath}/bin`] })

    // Unpack the binary
    await run({ cmd: ["tar", "-Jxf", binaryFileName, "-C", `${cellarPath}/bin`] })

    // Create INSTALL_RECEIPT.json
    const receipt = {
      formula: "Pkgx",
      version: newVersion,
      built_as_bottle: true,
      plist: null,
      time: new Date().getTime(),
      source_files: `/${prefix}/Library/Taps/pkgxdev/pkgx/Formula/Pkgx.rb`,
      source_modified_time: new Date().getTime(),
      HEAD: "HEAD",
      stdlib: null,
      arch: platform.split("+")[1],
    }
    await Deno.writeTextFile(`${cellarPath}/INSTALL_RECEIPT.json`, JSON.stringify(receipt))

    // Compress everything into a .tar.gz
    const platformTag = mapPlatformToBottleTag(platform)
    const bottleFilename = `bottles/pkgx-${newVersion}.${platformTag}.bottle.tar.gz`

    await run({ cmd: ["tar", "-czf", bottleFilename, cellarPath] })
    await run({ cmd: ["rm", "-rf", cellarPath] })

    const sha256Bottle = (await backticks({cmd: ["shasum", "-a", "256", bottleFilename]})).split(" ")[0]
    const uploadUrl = `${rootUrl}/v${newVersion}/${bottleFilename}`
    bottles.push({ platform: platformTag, sha256: sha256Bottle, url: uploadUrl })
  }
  return bottles
}

function mapPlatformToBottleTag(platform: string): string {
  // Map your platform strings to Homebrew bottle tags
  // This is just an example; adapt it to your needs
  switch (platform) {
    case 'darwin+aarch64': return 'arm64_big_sur'
    case 'darwin+x86-64': return 'big_sur'
    // case 'linux+aarch64': return 'arm64_linux'  // not supported for bottles yet
    case 'linux+x86-64': return 'x86_64_linux'
    default: throw new Error(`Unknown platform: ${platform}`)
  }
}

function generateBottleBlock(bottles: Bottle[], version: string) {
  let bottleBlock = "bottle do\n"
  for (const { platform, sha256 } of bottles) {
    if (platform === "x86_64_linux") {
      bottleBlock += "" +
      "    # Linux bottles fail currently: patchelf breaks deno compiled binaries.\n" +
      "    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42\n" +
      "    # and it's not possible to skip relocation in linuxbrew:\n" +
      "    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb\n" +
      `    #sha256 cellar: :any_skip_relocation, ${platform}: "${sha256}"\n`
    } else {
      bottleBlock += `    sha256 cellar: :any_skip_relocation, ${platform}: "${sha256}"\n`
    }
  }
  bottleBlock += `    root_url "${rootUrl}/v${version}"\n`
  bottleBlock += "  end"
  return bottleBlock
}
