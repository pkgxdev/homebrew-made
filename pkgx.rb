class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.3.2/pkgx-2.3.2.tar.xz"
  sha256 "f36aa7b128b1d387991708fbfd77eb2fdd93bdb1b6da7c3436173eb82f130a27"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b5a75b252c9aaad4b4f389cfbfafb956f035626630dcd365cb21be4c5b865743"
    sha256 cellar: :any_skip_relocation, big_sur: "a6517510f05b7e610b7131c2dc86d2abfe82aa31a471035441e775934f9bc409"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2ab932110c0ef094ef9cc839cfa56c0740a8100898495d2ac53e834524132e2d"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.3.2"
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
