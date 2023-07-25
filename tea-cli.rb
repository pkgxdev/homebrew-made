class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.0/tea-0.39.0.tar.xz"
  sha256 "58a0e7cc33b6d46c8cc8f886eb914c153272c135971e21b49126ae1ee49a218d"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "dad2db6b976f6818e05ff664c30644163c149a3baef6e9257e493087eaae9fca"
    sha256 cellar: :any_skip_relocation, big_sur: "b7231e0717acf06840119fa11e574954a062692b01ff04c9904a814093939edc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4a6dd1d259322f50259e59fb4fa2a1b4d4730a048659f82116f6ff2147833da0"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.0"
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
