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
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "870330d6a1ee55356f876d062bad28f2d4a2e7c7ee24e61d5155ec9310a33be3"
    sha256 cellar: :any_skip_relocation, big_sur: "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c7167aedfb196135460b363a5b5ecd419acd205937e80ec1284df5893af50842"
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
