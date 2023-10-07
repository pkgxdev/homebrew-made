class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.0.1/pkgx-1.0.1.tar.xz"
  sha256 "fc1a230fc4a9f61d4f4a1a7a96d5c9735c133c6ecbfcbf73457567ebcda71409"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "3cde0048ec1c76bebbd41771b448d8444944ae5644f8a25050ef9cd5f5d0467b"
    sha256 cellar: :any_skip_relocation, big_sur: "a848e829b053a033941fa0f96ba8527352be595db24c1eeb517bd54a29b84138"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "55e8cc697ea2bfce9e204db399b6e0887a49633d447c0ef615343535ec07dbce"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.0.1"
  end

  depends_on "deno" => :build

  def install
    system "deno", "task", "compile"

    bin.install "pkgx"
  end

  def caveats
    <<~EOS
      try it out:

          pkgx node@18 --eval 'console.log("pkgx: run anything")'
    EOS
  end

  test do
    (testpath/"hello.js").write <<~EOS
      const middle="llo, w"
      console.log(`he${middle}orld`);
    EOS

    with_env("PKGX_DIR" => testpath/".pkgx") do
      assert_equal "hello, world", shell_output("#{bin}/pkgx '#{testpath}/hello.js'").chomp
    end
  end
end
