class Mash < Formula
  desc "Mash up millions of open source packages into monstrously powerful scripts"
  homepage "https://github.com/pkgxdev/mash"
  url "https://github.com/pkgxdev/mash/releases/download/v0.3.0/mash-v0.3.0.sh"
  sha256 "88b5319d8e5f9bd3c01ef9e29867ef75908b11acbd22c2b1dd8eba18677778e3"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "pkgx"

  def install
    bin.install("mash-v#{version}.sh" => "mash")
  end

  test do
    system("#{bin}/mash demo test-pattern")
  end
end
