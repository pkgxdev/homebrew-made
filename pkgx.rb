class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.0.0/pkgx-2.0.0.tar.xz"
  sha256 "9a236947e95e31e55349b0e517b9529e1fffae16d7d51df609f811c7d37ea175"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "11766d5262265c9652ec7456b4df19c14f6c60478c98cbf80c3415a4158efe10"
    sha256 cellar: :any_skip_relocation, big_sur: "d13bbcaa822abf3f98e7930cc54f08373695eab2ce675cc9adb1a22889a3ac90"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4c5b8b8a3d7046c2328b8849fcc7b8012e41e872b113952de83139e8bd1deb88"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.0.0"
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
