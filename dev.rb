class Dev < Formula
  desc "Isolated `dev` environments"
  homepage "https://github.com/pkgxdev/dev"
  url "https://github.com/pkgxdev/dev/archive/refs/tags/v1.8.0.tar.gz"
  sha256 "0270489c1342540b87a1ac34089477a6e23b048d24c8b39a596b8daaceaa5b5a"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "pkgx"
  depends_on "deno"

  def install
    src = prefix.join("private")
    src.install("app.ts")
    src.install("src")
    src.install("deno.json")
    src.install("deno.lock")

    inreplace src/"app.ts", %r{/usr/bin/env -S pkgx.* deno.* run}, "#{HOMEBREW_PREFIX}/bin/deno run"

    bin.write_exec_script(src/"app.ts")
    FileUtils.mv bin.join("app.ts"), bin.join("dev")

    version_file = src.join("src/app-version.ts")
    version_file.delete()
    version_file.write("export default \"#{version}\";")
  end

  test do
    system("#{bin}/dev --version")
  end
end
