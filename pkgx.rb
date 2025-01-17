class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.1.1/pkgx-2.1.1.tar.xz"
  sha256 "326dfd5e3e9dc49169e328fb3d781f4c5c845c8ae8303d76171ee121c042103c"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "840e58f5eb5cf6d2c1f308256b31a6d308835b48a44d40c7705aefceff2c4d17"
    sha256 cellar: :any_skip_relocation, big_sur: "3e5099611aa9b5769a4771358be622dcd2f605db02de94f630b2dfbcf77cfd74"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "225762a52849d2c3c04adfa880d14a2cd296f0e2086ff28840e5f48d5b071f31"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.1.1"
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
