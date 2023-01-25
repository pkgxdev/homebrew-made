class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.21.2/tea-0.21.2.tar.xz"
  sha256 "20b84619f6ec06875a63edc3861615c5f40db30de436c551cf8e25073106212f"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "deno" => :build

  conflicts_with "tea", because: "both install `tea` binaries"

  def install
    system "deno", "task", "compile"

    bin.install "tea"
  end

  def caveats
    <<~EOS
      You must sync pantries before most commands will work:
      
          tea --sync -n
    
      tea’s shell magic is its secret sauce †
      If you want it add the following to your shell’s config file:

          source <(tea --magic)
      
      > † https://github.com/teaxyz/cli#magic
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
