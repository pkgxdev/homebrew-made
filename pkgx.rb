class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.1.0/pkgx-2.1.0.tar.xz"
  sha256 "631b06bd32ec79b736c00f1857a3a6538e2fd2ad761653cc4f053d4ba2c04ebc"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "38278904a77825ff4dac10ec7cf405d29ec22234c4c52875fef168b753e8653f"
    sha256 cellar: :any_skip_relocation, big_sur: "2ca7fc1dfd4412c49a09b770f88e39875903a93ba309e301b0cdb84a65d0e6aa"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6769abcb8aad8f0c787cedda98225bf3db64138dd1f20ffc0e415cec3e5d47f9"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.1.0"
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
