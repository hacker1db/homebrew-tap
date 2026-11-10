class AiUsage < Formula
  desc "Local dashboard and reports for AI coding tool usage"
  homepage "https://github.com/hacker1db/ai-usage"
  url "https://github.com/hacker1db/ai-usage/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "dc47d092e55056a628321d25da2f171152f2fb3c15f550ea02fceaf11ec18341"
  head "https://github.com/hacker1db/ai-usage.git", branch: "main"

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X main.version=v#{version}"), "./cmd/ai-usage"
  end

  test do
    assert_match "v#{version}", shell_output("#{bin}/ai-usage version")
  end
end
