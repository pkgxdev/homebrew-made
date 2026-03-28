class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.10.2/pkgx-2.10.2.tar.xz"
  sha256 "3f8320c513981153601d5c2e9ff35c4905b9702f761d2d3168e50e810e3443f5"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "766acdcd4a075a6bf026f38665fb74b769f12a9a7a6f6b04de386067fa77c10a"
    sha256 cellar: :any_skip_relocation, big_sur: "5375bc21f9517c18ed2ced0e97b757242a306ef932ab1f19a2b42ee565ce532d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "bd1eae1087990627b01193502592e4037636ce39691dc404855a6bf2b0833704"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.10.2"
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
