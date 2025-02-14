class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.3.1/pkgx-2.3.1.tar.xz"
  sha256 "f6e00d2bc91e94070ae13585eab7cdb6ea79501da53a59a07160b91a81cafef9"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "cc9ad529c26f70b865bf8a13f9dd96a71a19ad3a6410b337675e9c1edc31c9aa"
    sha256 cellar: :any_skip_relocation, big_sur: "080fad27cab2a020ab053d79117f817b8487d600b51dda2c44341fc1a8cfc094"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "955621c256bb0b5e6458137455f130da52e0f33912c2d444872a89f6b4616c5d"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.3.1"
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
