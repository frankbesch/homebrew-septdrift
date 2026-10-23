class Septdrift < Formula
  desc "Regression tests for Apple Foundation Models: record, diff, exit 1 on a flip"
  homepage "https://github.com/frankbesch/septdrift"
  url "https://github.com/frankbesch/septdrift/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "6816564b20fcb737a28b2a54faf4887c8ae209e3b01a1814747867735d7de69a"
  license "MIT"
  head "https://github.com/frankbesch/septdrift.git", branch: "main"

  depends_on macos: :golden_gate

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release"
    bin.install ".build/release/septdrift"
  end

  test do
    assert_match "0.1.0", shell_output("#{bin}/septdrift --version")
    (testpath/"cases.yaml").write <<~YAML
      - id: hello
        prompt: "Say hello."
        format: text
        checks:
          - contains: "hello"
    YAML
    (testpath/"fixtures.jsonl").write <<~JSON
      {"caseID": "hello", "rep": 0, "content": "hello there", "wallMs": 10}
    JSON
    system bin/"septdrift", "run", testpath/"cases.yaml", "--backend", "fixture",
           "--fixtures", testpath/"fixtures.jsonl", "--out", testpath/"a.jsonl", "--no-hostname"
    assert_match "OK 1 results", shell_output("#{bin}/septdrift verify #{testpath}/a.jsonl")
  end
end
