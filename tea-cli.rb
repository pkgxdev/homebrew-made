class TeaCli < Formula
  desc "builders ❤️ tea"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.6/tea-0.39.6.tar.xz"
  sha256 "32f0e6591703e1267b5556210a3bc27c37afeae0c57be88ce813faae5497cc04"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "b330a7fa1465dd321a76048a8300713b126821ccd7a8b92b38221a8ae012be1e"
    sha256 cellar: :any_skip_relocation, big_sur: "e28c5dfc43497c78a3e0e8fdd92ece7cd328038369b891c37872ad8a6c8dec71"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/teaxyz/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "0316d7287f595ae9c57760e7d4adc220a7ed1081683ecfd828bbfb852ae7207a"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.6"
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
