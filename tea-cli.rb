class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.25.3/tea-0.25.3.tar.xz"
  sha256 "c4afecaca1ebd9af1d73ebeb4d2c47117eacef6c23e823f943f29b5965cae3d8"
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
