class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.10.3/pkgx-2.10.3.tar.xz"
  sha256 "19d334093fca5f1074ea881977d1443bd568a97d9715dab063a43ba287da9fe5"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "99e7f3d1621b70688cbbf5572935221f19ca54469296ae8adff56c97497c1c7f"
    sha256 cellar: :any_skip_relocation, big_sur: "84153ff710983b33157574f97e69ddecd257c4ac1507a97f1dfbbccce9238828"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "55c46cbd0836741c62552e358e64721db8793474ef8c7e2b5260f5dc9546300a"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.10.3"
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
