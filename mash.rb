class Mash < Formula
  desc "Mash up millions of open source packages into monstrously powerful scripts"
  homepage "https://github.com/pkgxdev/mash"
  url "https://github.com/pkgxdev/mash/releases/download/v0.4.0/mash-v0.4.0.sh"
  sha256 "7ac8d2ab683007e4b0631cbf57ef602d4259db3896a7422356b3186e95abed8f"
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
