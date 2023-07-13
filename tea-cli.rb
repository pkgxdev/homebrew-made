class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.38.3/tea-0.38.3.tar.xz"
  sha256 "d05b38477d72fd01d66092838c948d01acf68e76326081187430666037a8f015"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "be0e4e07a858deee203a4a86b79c6667ce362a94a8140b5b727998a8e8712015"
    sha256 cellar: :any_skip_relocation, big_sur: "eeeebd7d807841213476f5f4fe98721d9f5452c8a8734b4f5d4de4bb8c61a669"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "35b26cddab9d473e775089c769d6dabc6e1ac8fb8f4d378f44b36dd734a37bac"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.38.3"
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
