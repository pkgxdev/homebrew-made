class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.7.0/pkgx-2.7.0.tar.xz"
  sha256 "abceecdde37c4648b5486c164b5ccbf8e443ffc2a9bf9263cc5bcaa2c2d58dec"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "7947e06855a1b2d441076337fbb511413ce05491c43965b5628e5715c4991181"
    sha256 cellar: :any_skip_relocation, big_sur: "311a5b0ecaaf3ed404f9d67aac9ba93b48575050de5617e3b9fb33f404d84e88"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "31794ba3c0f4f585ddddb56004d16c7a12ffb632c5d7e03370487c9de66e7a2c"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.7.0"
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
