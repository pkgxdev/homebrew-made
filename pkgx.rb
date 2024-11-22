class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.3.0/pkgx-1.3.0.tar.xz"
  sha256 "0562adb4c5035e31b8c273b0de667272855868775763785d822249f6ffaa09db"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "730c4060ed58ff86712443c29bd6d1d33ca3fc8fb7dd72de229c92ead6b68a83"
    sha256 cellar: :any_skip_relocation, big_sur: "843abaca76af1e1199cf7139b4569c3849b10b40af6009c20cb7b5d13a8fd4ca"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "f406ceb7cc699231ff1a094e0843c652720b64dd3f42df708005ea1381a16969"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.3.0"
  end

  depends_on "deno" => :build
  depends_on "unzip" => :build # deno >=1.39.1 uses unzip when remote-fetching their compilable runtime

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
