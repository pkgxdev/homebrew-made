class Pkgm < Formula
  desc "Install Anything"
  homepage "https://github.com/pkgxdev/pkgm"
  sha256 "0c988b475c7e52d4a7ee429f5ffab781f83187743e738a31639fc546fbf1d870"
  url "https://github.com/pkgxdev/pkgm/releases/download/v0.11.0/pkgm-0.11.0.tgz"
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
