class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.4/tea-0.39.4.tar.xz"
  sha256 "3ae120b842c4996c2ddb844ebb950c6e74dd53d74c48b8f3f3ac3850d51a4d0c"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "0a8e970c997254a117533473604a30afe28f465b1376688182d522af7a342a60"
    sha256 cellar: :any_skip_relocation, big_sur: "3a994b7f92c0028008bdedf246e85425999187165618fa91e56cca4fb1c2a7d5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7e5248096ef6244222f2c31cc20018c5312d2b7934d0391609f27497623f1926"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.4"
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
