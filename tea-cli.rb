class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.2/tea-0.39.2.tar.xz"
  sha256 "59cf9ef31a9ac851d52f5fb66ebd0db6b67b001e9d3588b27e9882493f48d4cf"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "dfaa50f1300fddb59709293839efad175d3b3352c8b189d59f21a65b7e54c920"
    sha256 cellar: :any_skip_relocation, big_sur: "f4cee299fd87c5daf1136d5710f62eedc9a678d6fb98770d126986c39a9d9032"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "923ba0d2f73985fbfe7f8271c50e2670ab468048a1c3368f85a0f749bb450b1d"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.2"
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
