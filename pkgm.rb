class Pkgm < Formula
  desc "Install Anything"
  homepage "https://github.com/pkgxdev/pkgm"
  sha256 "09802b6fdfb17ac6ae94ae4249f331d93eb5c3de8c43030c129bb7760e6efe50"
  url "https://github.com/pkgxdev/pkgm/releases/download/v0.7.1/pkgm-0.7.1.tgz"
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
