class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.0.2/pkgx-1.0.2.tar.xz"
  sha256 "538e560e32769e0b21d8a117122a6b1007f130e63600428f1c95bcc02f631f0c"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "629956c273c1c5684c6f922e857cdbe097d7740083e42dbb8f0398c52a681bb9"
    sha256 cellar: :any_skip_relocation, big_sur: "b43763e4ba14f8f9516f84170aa40c5dc315d93d47e3bfb5033679e9ec90dc57"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "a978cbeeca1bde0cd2e3475da25c41dadc3f3df3bca746ba4bba60bb0ed28e9a"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.0.2"
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

      shell integration:

          pkgx integrate --dry-run
          # ^^ https://docs.pkgx.sh/shell-integration
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
