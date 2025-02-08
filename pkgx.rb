class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.2.1/pkgx-2.2.1.tar.xz"
  sha256 "5b2b1a3bad0f3bc8a2a60956aecc55a75c67aa99505fcbe37675b8a326a8c7c7"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "02520ea8127e3d143017b24c55a3a1b3168075b0f1e9c505040d866e508d816b"
    sha256 cellar: :any_skip_relocation, big_sur: "b6ea7fa519e31e3b7561dcb56112dce206589b1b15d704b9d0b5784765d6896b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9730c1a9e2cf80abc48fa7f21bdf70c9dc202bb33386b87bbcda0642b80b97a7"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.2.1"
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
