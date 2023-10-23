class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.0.4/pkgx-1.0.4.tar.xz"
  sha256 "aa41b50932d009f0fa37482c349300c15263c477cbd6b9d7fa9dd6aef5a465c6"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "9bdf3ace44d7f8e7df4a2c3c97b70ada06b883d935a7c4aee6e3922d7b598b67"
    sha256 cellar: :any_skip_relocation, big_sur: "289a6030e880f5cdf1646e5a6351698a1edf400d7778d31e5754bbd3e2baa99d"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "154405ade3d6f24c2adb9b9329f50bd0cc0cf4c56f288a2a480b4df2a4f8bd44"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.0.4"
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
