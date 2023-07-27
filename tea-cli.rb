class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.3/tea-0.39.3.tar.xz"
  sha256 "8253b39415eff78b9de0ca856038428a783ff0b21d3a976bcd8c60a4292c3fe8"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "dda82af1e777fbf75777a65c66aa326ca56cdb90460fb5a3ddf39d856e565a0e"
    sha256 cellar: :any_skip_relocation, big_sur: "cf79c950f14e975b8427daa415689c190ab85a160e9667079854c94e2edb8f6c"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d88930027226e8ae156ef4b88a8921140a6ff55fb335a0dab0eb602e96a9f3c5"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.3"
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
