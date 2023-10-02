class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.0.0/pkgx-1.0.0.tar.xz"
  sha256 "cff868b8618c70d1b14821ed0a0602129f133acffb3143efd2b886666c3b6c69"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "c51d83149eb04360d3c887832f45cfe875b7640ebc281a88b608461491cbc198"
    sha256 cellar: :any_skip_relocation, big_sur: "ca34c144b5af4dff7a69bc56906d5eff84cd0cb55ee9de65944ca70d0383d614"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "92d2b4a1f991a3b83ed6f21f898d904e7666eb63c8cf45cbc11f3cb3cc90a58b"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.0.0"
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
