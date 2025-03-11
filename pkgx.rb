class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.4.0/pkgx-2.4.0.tar.xz"
  sha256 "bb80a5bd79a387762535e976e987d4c91aafe70913b2f891bc92338d089f9208"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "2a8b39870135945d8d156c7f89f8ce1177379eef0fe9baf5ab6f78132fc4bd94"
    sha256 cellar: :any_skip_relocation, big_sur: "9943d56f94817cd2849af327630ef99709dabb6f5f92fc4aea4cc00edc6c8692"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b3960beb9be44eaf791e129cf9cc3b4cfa75abf2b98c83d93f2167cdf615d014"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.4.0"
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
