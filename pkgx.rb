class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.1.5/pkgx-1.1.5.tar.xz"
  sha256 "73f36099c37043699226e35d6be06b2445bb0bd18cc62e2653c08d254a2c38eb"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "cfc801e5f2dfdc49806518e4e314a5ae6bbdf02a8a728df4410c365924846fcd"
    sha256 cellar: :any_skip_relocation, big_sur: "0d41807a56b4f1102c313321abc2aaf64c8d67fae5038f4b525c5658725fedcc"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "02b8b3926ffd688935d9781031ef5ab6aa7bbd5bd910e5433929955e734d5f2c"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.1.5"
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
