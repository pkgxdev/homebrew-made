class TeaCli < Formula
  desc "builders ❤️ tea"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.5/tea-0.39.5.tar.xz"
  sha256 "f6ce28751654f9c7a96f49690dba171753e0d1c44416f6a9e681203112a4b694"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "3af398467295b3666e14bd315a252b3cba2fa8b70c04d851d4b9d51666ae4ed9"
    sha256 cellar: :any_skip_relocation, big_sur: "a6b273b1347b97a1a09f26ba8126952a744e371b71ef610db5b6c7bb5233e77a"
      # Linux bottles fail currently: patchelf breaks deno compiled binaries.
      # https://github.com/teaxyz/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
      # and it's not possible to skip relocation in linuxbrew:
      # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.5"
  end

  depends_on "deno" => :build

  conflicts_with "tea", because: "both install `tea` binaries"

  def install
    system "deno", "task", "compile"

    bin.install "tea"
  end

  def caveats
    <<~EOS
      try it out:

          tea node@18 -e 'console.log("brewing up some tea")'

      tea’s shell magic is its secret sauce †

          tea --magic=install

      > † https://docs.tea.xyz/features/magic
    EOS
  end

  test do
    (testpath/"hello.js").write <<~EOS
      const middle="llo, w"
      console.log(`he${middle}orld`);
    EOS

    with_env("TEA_PREFIX" => testpath/".tea") do
      system bin/"tea --sync"

      assert_equal "hello, world", shell_output("#{bin}/tea '#{testpath}/hello.js'").chomp
    end
  end
end
