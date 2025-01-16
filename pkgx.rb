class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.0.0/pkgx-2.0.0.tar.xz"
  sha256 "c2f43c1a0bedc0749da38066cff11d69596e3d3763ea4f73f9e3be8b68b2b787"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "e7a091a30faf726ae328bad61edc757e64d145f39ace158b4c436a91be688274"
    sha256 cellar: :any_skip_relocation, big_sur: "8522e8d982e1bb1a624e1faf77468e4500e542b0931ca707d1470f81b7c764a0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "cd2e8fa69bf8b05ec2d61b900734c4d76cce82be50a6fd9b4b3318627764f96e"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.0.0"
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
