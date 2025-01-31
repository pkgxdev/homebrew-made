class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.2.0/pkgx-2.2.0.tar.xz"
  sha256 "f39ac2cbdc4a6fcb8f918f18ac9d4ecd982ad04573b9865c8a5481b869f3d381"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "a61d961b4c2a611d521221d3f18ed3e7f82ca1fb2318f41060aead305fdf9968"
    sha256 cellar: :any_skip_relocation, big_sur: "008240b4e66b7ac2b2f8aeff35185e223fcd2b02e4a89e8ec48bb6b15e97b210"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "91c34fccceaa60930eccee125b53e0cc4f44caa5382e9275b1e947429dba2719"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.2.0"
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
