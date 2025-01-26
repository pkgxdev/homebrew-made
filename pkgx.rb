class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.1.3/pkgx-2.1.3.tar.xz"
  sha256 "494a13b363c6196a8fcff94e1a1502c4df9a57a2557b5de8d551a2a7401e0672"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "48f97c9075e933949025febcbdc17ec2597e47695f8ae042cd83680ec1fac339"
    sha256 cellar: :any_skip_relocation, big_sur: "e8a9070e469409be259cf48e798033b4f9640123cef5efa9ab4e5bd9652fdb18"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "9298f5cf9735b4a53327b1bb359231be89abff5b8b9c6faca61ba79a6bdea2c6"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.1.3"
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
