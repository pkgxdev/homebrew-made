class TeaCli < Formula
  desc "builders ❤️ tea"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v1.0.0-alpha.2/tea-1.0.0-alpha.2.tar.xz"
  sha256 "ea412dd0cdb597fc0af7d0830c8cd658969c74c25eee8c9f82bee29f290efd15"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "a428962b1dc96f09cdc952029b6b584dc133e10310e72ab9acdb97b755d2e3ea"
    sha256 cellar: :any_skip_relocation, big_sur: "df77276730d6b3204fb999f0e28af483d0ca4d2d69af73e2cc781d7daa1a201f"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/teaxyz/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "63a959204249be2961752502c263755bb7dbb97bad2d1d5e28c61b61ac3d9e44"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v1.0.0-alpha.2"
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
