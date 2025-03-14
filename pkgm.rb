class Pkgm < Formula
  desc "Install Anything"
  homepage "https://github.com/pkgxdev/pkgm"
  sha256 "459d1d1c3ec9f0a160ea8178514437dc93159f6b50ae039325921e5691a4fd95"
  url "https://github.com/pkgxdev/pkgm/releases/download/v0.8.0/pkgm-0.8.0.tgz"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "deno"
  depends_on "pkgx"

  def install
    # use the brew deno rather than pkgx deno
    # NOTE maybe pointless since internally it uses `pkgx deno` still, but we could fix that…
    inreplace "pkgm", /pkgx --quiet deno.* run/, "deno run"

    bin.install("pkgm")
  end

  test do
    assert_equal shell_output("#{bin}/pkgm --version").chomp, "pkgm #{version}"
  end
end
