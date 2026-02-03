class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.9.0/pkgx-2.9.0.tar.xz"
  sha256 "05ffa54721cc79580cfd197a60d1580de169689d493480f3b1c21e34b85afa12"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "ed344834e15259fae0684235b65a22388cf59924ad3baff63c62882b53bffb74"
    sha256 cellar: :any_skip_relocation, big_sur: "27ebb3591eb6951ebefb9c466a03431adfaa3d479e80bfea69da9f3b917d43c7"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ecfb76a8753bfe0666e296b7666b0a85e904f79d3d2af872d4e01e8f0700a519"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.9.0"
  end

  depends_on "deno" => :build
  depends_on "unzip" => :build # deno >=1.39.1 uses unzip when remote-fetching their compilable runtime
  depends_on "rust" => :build
  depends_on "openssl" => :build

  def install
    if File.file? "Cargo.toml"
      system "cargo", "build", "--release"
      bin.install "target/release/pkgx"
    else
      system "deno", "task", "compile"
      bin.install "pkgx"
    end
  end

  test do
    (testpath/"hello.js").write <<~EOS
      const middle="llo, w"
      console.log(`he${middle}orld`);
    EOS

    with_env("PKGX_DIR" => testpath/".pkgx") do
      assert_equal "hello, world", shell_output("#{bin}/pkgx deno run '#{testpath}/hello.js'").chomp
    end
  end
end
