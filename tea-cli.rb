class TeaCli < Formula
  desc "builders ❤️ tea"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v1.0.0-alpha.3/tea-1.0.0-alpha.3.tar.xz"
  sha256 "a8981b8a540bb6bd9856d45cd4c5a0f03a97c0a1591f4d7255ffda6b21be923c"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "d061745595088f17221a0bcd3bdb2e8e2286f08d217743993eb6e5aabe80db42"
    sha256 cellar: :any_skip_relocation, big_sur: "ea6dbcc9dcc36200ceb60b8525cac3208bcb989be38ba8d8f1a5c48310182371"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/teaxyz/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "88bebb37a82c5e2005e70347c853c593d3e5b31cc31a662a982e5b422926871a"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v1.0.0-alpha.3"
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

          tea node@18 --eval 'console.log("brewing up some tea")'
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
