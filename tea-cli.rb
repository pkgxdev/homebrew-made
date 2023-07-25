class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.38.4/tea-0.38.4.tar.xz"
  sha256 "f5828871c5d1cf470b9ba0a46ceb37a763fe95c2ff509b41e2592a39e84ea48c"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "beed66e456965d384c0739137288e3c6a6d54f8409251c6190d4c135cab24e9a"
    sha256 cellar: :any_skip_relocation, big_sur: "75c67f59c3cdc80d7acd70510c52762050bd86378d97eead2dd874d1c8c83c3d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "516d6e5fba387b9579409b6cd979e560e8ec89355f86605e85912b7af8d78830"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.38.4"
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
