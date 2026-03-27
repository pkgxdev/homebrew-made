class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.10.1/pkgx-2.10.1.tar.xz"
  sha256 "51e34a54c942e10a1b81d004ec2539b004ff3d4759265c8bd41696aaf93f755a"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "54a80362ef4ae6ad620f89a69638698a3932e1dae49df8a57df7dd9b649f0cea"
    sha256 cellar: :any_skip_relocation, big_sur: "c324c16c990dae9096fc24cf4dac607f7f6da4f8e0bef3df61269ec316d63338"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "12092aa836f03022cc9cd51c4c09cde3bbbe13fbe2bbb2728f3615f09220ea9b"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.10.1"
  end

  depends_on "deno" => :build
  depends_on "unzip" => :build # deno >=1.39.1 uses unzip when remote-fetching their compilable runtime
  depends_on "rust" => :build
  depends_on "openssl" => :build

  def install
    if File.file? "Cargo.toml"
      system "cargo", "build", "--release"
      bin.install "target/release/pkgx"
    else
      system "deno", "task", "compile"
      bin.install "pkgx"
    end
  end

  test do
    (testpath/"hello.js").write <<~EOS
      const middle="llo, w"
      console.log(`he${middle}orld`);
    EOS

    with_env("PKGX_DIR" => testpath/".pkgx") do
      assert_equal "hello, world", shell_output("#{bin}/pkgx deno run '#{testpath}/hello.js'").chomp
    end
  end
end
