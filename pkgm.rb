class Pkgm < Formula
  desc "Install Anything"
  homepage "https://github.com/pkgxdev/pkgm"
  sha256 "bf5cfe05d4d214f1c669e2e0057bc5088aa1327e905851ddd40ad86463e15a64"
  url "https://github.com/pkgxdev/pkgm/releases/download/v0.10.1/pkgm-0.10.1.tgz"
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
