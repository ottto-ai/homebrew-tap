# Generated from ottto-local-platform 0.1.152 (stable).
# Do not hand-edit: run tools/ottto-local-platform/scripts/homebrew_formula.sh.
class Ottto < Formula
  desc "Local Ottto CLI and per-user service"
  homepage "https://ottto.net"
  url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.152/ottto-macos-arm64.zip"
  version "0.1.152"
  sha256 "89b71bf9a64fa02a1f9ece7e5885d9f5294b98d467a5a7b4e49f516026050a75"
  license "Apache-2.0"

  depends_on arch: :arm64
  depends_on macos: :sonoma

  resource "ottto-service" do
    url "https://install.ottto.net/ottto-local-platform/releases/stable/0.1.152/ottto-service-macos-arm64.zip"
    sha256 "1a9a70430828086c4657fe6963c5a9ee4595d96b02d81d27676109daf21ff91a"
  end

  def install
    bin.install "ottto"

    resource("ottto-service").stage do
      daemons = Dir["*"].select { |path| File.file?(path) && File.executable?(path) }
      odie "ottto-service resource did not contain exactly one executable" if daemons.length != 1
      bin.install daemons.fetch(0) => "ottto-service"
    end
  end

  service do
    name macos: "net.ottto.service"
    run [
      opt_bin/"ottto-service",
      "serve",
      "--socket",
      "#{Dir.home}/Library/Application Support/Ottto/ottto-service.sock",
    ]
    keep_alive true
    environment_variables PATH: std_service_path_env
    log_path "#{Dir.home}/Library/Logs/Ottto/ottto-service.log"
    error_log_path "#{Dir.home}/Library/Logs/Ottto/ottto-service.error.log"
  end

  def caveats
    <<~EOS
      Start the Ottto local service:
        brew services start ottto

      Check status after the service is started:
        ottto --no-autostart status --json

      Update this Homebrew-managed install:
        brew update && brew upgrade ottto
        brew services restart ottto

      Stop and uninstall:
        brew services stop ottto
        brew uninstall ottto

      The Homebrew service owns launchd label net.ottto.service and the default
      per-user socket at ~/Library/Application Support/Ottto/ottto-service.sock.
      If Ottto.app is also installed, leave service lifecycle with Homebrew; the
      app connects to the Homebrew-owned service instead of replacing it.
    EOS
  end

  test do
    system bin/"ottto", "--help"
    system bin/"ottto-service", "--help"
  end
end
