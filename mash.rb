class Mash < Formula
  desc "Mash up millions of open source packages into monstrously powerful scripts"
  homepage "https://github.com/pkgxdev/mash"
  url "https://github.com/pkgxdev/mash/releases/download/v0.3.1/mash-v0.3.1.sh"
  sha256 "4cb0103f8ddb7cd0f6203e4ab935d2a80d41c70840336dd5c3ca92a2c1c6a29c"
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
