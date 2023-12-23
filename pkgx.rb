class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v1.1.3/pkgx-1.1.3.tar.xz"
  sha256 "c92075a5faaae507579b7e2e565cabed866b1d7c85cfe1fea2e9db52b3734d4e"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "25a5ce526b1b5b368a96d64d2b3cb1a007b0e9470c32c9fef87b5eaa2a86cdae"
    sha256 cellar: :any_skip_relocation, big_sur: "e179b2b6bbffef29e56e773302794769f412d107ec4b031d42d50a5ebea5dbe9"
    # Linux bottles fail currently: patchelf breaks deno compiled binaries.
    # https://github.com/pkgxdev/brewkit/blob/main/share/brewkit/fix-elf.ts#L38-L42
    # and it's not possible to skip relocation in linuxbrew:
    # https://github.com/Homebrew/brew/blob/d1f60aea49d35fc0ba8f02a1f4fd26d0a369e071/Library/Homebrew/extend/os/linux/software_spec.rb
    #sha256 cellar: :any_skip_relocation, x86_64_linux: "5720ab623286291f02622156ad39d9b0f4368315d380a4b1ff8906e1fa0c391f"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v1.1.3"
  end

  depends_on "deno" => :build

  def install
    system "deno", "task", "compile"

    bin.install "pkgx"
  end

  def caveats
    <<~EOS
      try it out:

          pkgx node@18 --eval 'console.log("pkgx: run anything")'

      shell integration:

          pkgx integrate --dry-run
          # ^^ https://docs.pkgx.sh/shell-integration
    EOS
  end

  test do
    (testpath/"hello.js").write <<~EOS
      const middle="llo, w"
      console.log(`he${middle}orld`);
    EOS

    with_env("PKGX_DIR" => testpath/".pkgx") do
      assert_equal "hello, world", shell_output("#{bin}/pkgx '#{testpath}/hello.js'").chomp
    end
  end
end
