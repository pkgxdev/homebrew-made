class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.5.0/pkgx-2.5.0.tar.xz"
  sha256 "02e54109df4c5a8722d0709aea76ac147ecfeab33ca2160ddb21d7938d4986e3"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "50ef78b24fa655ea88d88c3eb6dbe6c93a58a5d619bdced21aeccb5f8100d832"
    sha256 cellar: :any_skip_relocation, big_sur: "bf8e9d2de65331fa8be826b4c2c28ada7c11a7f50f5f3ee3a9bb3dc600c16824"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "770e070e99a5a28361e0e59eca09c4e461310847ebbc3681ef7fd96a36e6f6ae"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.5.0"
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
