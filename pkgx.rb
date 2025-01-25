class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.1.2/pkgx-2.1.2.tar.xz"
  sha256 "d6e81293df0b2e947f376e4a9d3d417a1a5fbc9ffd906eaf38cd41220599eda9"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "4689b6b972362343430b51390b11c246358e3e7fb2333c5965c3fd1af3ff9215"
    sha256 cellar: :any_skip_relocation, big_sur: "40a410b70d7472c042457141ba2278160d8271f7d96fa85e3dc99b0ce49d297d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e3d9efa0a736105e0cc49cac50359760b5b783673e8ca831f027ed27cf972be5"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.1.2"
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
