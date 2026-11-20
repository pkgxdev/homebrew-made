class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.11.1/pkgx-2.11.1.tar.xz"
  sha256 "0ff710a185553276b4efc1fe5493d6a9e5259c9a2559389e1645b4063507c6bf"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "7bce16caa733ad9e70d8676f0c00565ce8d068f22e27a38b3a6bb1391d054e0c"
    sha256 cellar: :any_skip_relocation, big_sur: "a213b96a2be456755a315f513b8d304a4295ed29e7aad5b3e5e10198eef8a609"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6a3000a3cfd17cb7086577e9408234c894393ad1903a651675c38628c0614507"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.11.1"
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
