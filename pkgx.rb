class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.3.0/pkgx-2.3.0.tar.xz"
  sha256 "6f6c4c2753a4774c7f72432dbb54f22fb48b98eed0b3d8576480217dffe8c8a1"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b64a349915cb36720feae94c901c40f2dcd042479eebebea090e20b45acfb47d"
    sha256 cellar: :any_skip_relocation, big_sur: "4d799cf5150196b633dadba0dbefea52e4950413c4fd874b6d221a8f3adb575c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e3b06ebbbc4c2828344a07042811cd7ecc1545d0b2d40a613635066a9b2fb4df"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.3.0"
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
