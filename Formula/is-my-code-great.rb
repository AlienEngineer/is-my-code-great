class IsMyCodeGreat < Formula
  desc "CLI to analyse Dart test code quality"
  homepage "https://github.com/AlienEngineer/is-my-code-great"
  url      "https://github.com/AlienEngineer/is-my-code-great/archive/v0.1.0.tar.gz"
  sha256   "ac3fd9e9008ce58b6aefaf3a965dd08db77fe4f07645a48536a3bc44f6ca3b4b"

  def install
    lib.install Dir["lib/*"]
    bin.install "bin/is-my-code-great"
  end

  test do
    system "#{bin}/is-my-code-great", "--help"
  end
end
