class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.6.0/pkgx-2.6.0.tar.xz"
  sha256 "49fc9fcb830d4d51836ccca7ec1af55327d3eafa46286875bc3f612a2f7eb7b8"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "fe85d19b0ef94c519c1e000c24fcba11e22b7af06e94a033ec0668dfd8e2e24c"
    sha256 cellar: :any_skip_relocation, big_sur: "f1db38560c877395de5a598df3a4e690dbf55ce19d45b3a79a2510d62d76fce1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c4369bb410440d8f61bbcf323aac2ef2eb4c4e43a7cbf3feac86b55a0d82db9d"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.6.0"
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
