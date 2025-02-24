class Pkgm < Formula
  desc "Install Anything"
  homepage "https://github.com/pkgxdev/pkgm"
  sha256 "3ce959b6fcfbbd4924065caeeeb01bea3c20731d73bba6ed49b67e97d87b86cf"
  url "https://github.com/pkgxdev/pkgm/releases/download/v0.4.0/pkgm-0.4.0.tgz"
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
