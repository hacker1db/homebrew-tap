class JxscoutRs < Formula
  desc "JavaScript recon for security researchers: chunks, source maps, AST findings"
  homepage "https://github.com/hacker1db/jxscout-rs"
  license any_of: ["MIT", "Apache-2.0"]

  # Prebuilt release binaries. The version (in the URLs) and every `sha256` are rewritten by
  # .github/workflows/bump-jxscout-rs.yml when a new release is published.
  on_macos do
    on_arm do
      url "https://github.com/hacker1db/jxscout-rs/releases/download/v0.1.0/jxscout-rs-v0.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://github.com/hacker1db/jxscout-rs/releases/download/v0.1.0/jxscout-rs-v0.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/hacker1db/jxscout-rs/releases/download/v0.1.0/jxscout-rs-v0.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
    on_intel do
      url "https://github.com/hacker1db/jxscout-rs/releases/download/v0.1.0/jxscout-rs-v0.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    bin.install "jxscout-rs"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jxscout-rs --version")
    (testpath/"sample.js").write "eval(location.hash);\n"
    assert_match "Client Behavior/eval", shell_output("#{bin}/jxscout-rs analyze #{testpath}/sample.js")
  end
end
