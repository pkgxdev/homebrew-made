class Pkgx < Formula
  desc "Run Anything"
  homepage "https://pkgx.sh"
  url "https://github.com/pkgxdev/pkgx/releases/download/v2.11.0/pkgx-2.11.0.tar.xz"
  sha256 "30fbe794051d0897867206eb7895757fee7d4a99786ab4f69ee55fdc8a531597"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "71af393a4bd4606b2d205702abb8d98ec2afdcbc80d0153ca865311e7766bc6e"
    sha256 cellar: :any_skip_relocation, big_sur: "94e67e17cbc3c67560dc3afeac8916999dd8c9b40becfcbba723afee3d8de583"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d877d3426ca2c7eb7329eeae00582b39ffc3f6db04d25f4e99cad2db76fdf4d8"
    root_url "https://github.com/pkgxdev/homebrew-made/releases/download/v2.11.0"
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
