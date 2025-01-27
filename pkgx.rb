class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.1.4/pkgx-2.1.4.tar.xz"
  sha256 "629979377ab20f516d4f5ed3f1faf6d04e4b7c2a7958909f910af9ee658a316f"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "908027feb89f7ea5720725b54e88ffd35b219db3eb2a03e74ce62916a8657ff2"
    sha256 cellar: :any_skip_relocation, big_sur: "90d89f25339161333a04bc231108f8419f4ee0ee842173e30b7e2d5cb41b95ff"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1cfbc9eb961495a5718d3edf352db171278e54da40a4d4dad5cd6a455336fac6"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.1.4"
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
