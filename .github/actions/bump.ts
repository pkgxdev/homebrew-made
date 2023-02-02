#!/usr/bin/env -S tea -E

/*---
args:
  - deno
  - run
  - --allow-net
  - --allow-run
  - --allow-read
  - --allow-write=.
  - --allow-env
  - --unstable
  - --import-map=https://raw.githubusercontent.com/teaxyz/cli/v0.21/import-map.json
---*/

import { backticks, run, panic } from "utils"
import { basename } from "deno/path/mod.ts"
import { crypto, toHashString } from "deno/crypto/mod.ts"

const tap = Deno.env.get("TAP") ?? panic("No TAP specified")

const livecheck: LCResults[] = JSON.parse(await backticks({ cmd: ["brew", "livecheck", "--quiet", "--newer-only", "--full-name", "--json", `--tap=${tap}`] }))

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
    const newFormula = formula.replaceAll(url, newUrl).replace(/  sha256 ".+"/, `  sha256 "${newSha}"`)

    await Deno.writeTextFile(`${name}.rb`, newFormula)

    if (Deno.env.get("GITHUB_ACTIONS")) {
      await run({ cmd: ["git", "add", `${name}.rb`] })
      await run({ cmd: ["git", "commit", "-m", `bump ${name} from ${oldVersion} to ${newVersion}`] })
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