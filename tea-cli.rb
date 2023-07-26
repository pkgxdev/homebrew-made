class TeaCli < Formula
  desc "Unified package manager"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v0.39.1/tea-0.39.1.tar.xz"
  sha256 "f31756916283efe5e26e68431f53a8061a65d57f01eb1355e5e5d95c97314b5d"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "2f6d0644355315c3a25a01a45fe55fca78e4b7d725948c6947d7d0564a981d90"
    sha256 cellar: :any_skip_relocation, big_sur: "3b7f0ac1abeeb5e11d757873612b90bd66c61ea2228fac4523b55a68ebcd3f25"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c71bba6dae3fb717adade2fcfce6078c2f469d284d5aec6f4062bb940cb56e5e"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v0.39.1"
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
