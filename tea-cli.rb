class TeaCli < Formula
  desc "builders ❤️ tea"
  homepage "https://tea.xyz"
  url "https://github.com/teaxyz/cli/releases/download/v1.0.0-alpha.4/tea-1.0.0-alpha.4.tar.xz"
  sha256 "fbad7439b55fdc43c2b69ad5fbd76556326e89e749165c80f46761dd4b912b22"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "750c31e752ff55dfc63bbc1c2255c0e6cfe1db0ce3aaaf61809f2fa05597d139"
    sha256 cellar: :any_skip_relocation, big_sur: "f1d01c48a85caa5635a3f5bf6c25d59ecb87451091240249233b54e59ca63ce0"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/teaxyz/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "5d6267b14bfef33c80524867b9089adf830677c62cbd5ea662daed2a81e10d59"
    root_url "https://github.com/teaxyz/homebrew-pkgs/releases/download/v1.0.0-alpha.4"
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

          tea node@18 --eval 'console.log("brewing up some tea")'
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
