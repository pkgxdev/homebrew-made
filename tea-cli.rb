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
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "cb65972b132d174ef5ba8126d4b3809ca74184288efa6a78432000327f06951f"
    sha256 cellar: :any_skip_relocation, big_sur: "617eccb64b14951c7e13318aaba9b7551658c457363bdda35cc6ece1d1506049"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/teaxyz/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "35a19ce953f31c91c3b4a190e25fc02c715ba54fa90dc9e98dfdaa19582fbc0c"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v1.0.0-alpha.1"
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
