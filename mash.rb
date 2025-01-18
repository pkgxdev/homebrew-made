class Mash < Formula
  desc "Mash up millions of open source packages into monstrously powerful scripts"
  homepage "https://github.com/pkgxdev/mash"
  url "https://github.com/pkgxdev/mash/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "8a2f79573c6c1101fb65ebf6b898f8c32257e6c52aea80f8f9fd1266f258cebc"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "pkgx"

  def install
    bin.install("mash")
  end

  test do
    system("#{bin}/mash demo test-pattern")
  end
end
