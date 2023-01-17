class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.19.4/tea-0.19.4.tar.xz"
  sha256 "73c57b0f06b444ea26590831defb24b358f40114ab1be2cdf88d0dceb1acd2c9"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "deno" => :build

  conflicts_with "tea", because: "both install `tea` binaries"

  def install
    system "deno", "task", "compile", "tea"

    bin.install "tea"
  end

  def caveats
    <<~EOS
      Most commands will fail until you run `tea --sync` at least once.

      To install tea's shell magic (its secret sauce), add the following
        to your shell's config file:

      command -v tea && tea --magic --silent | source)

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
