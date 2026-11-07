cask "ottto-app" do
  version "0.1.230"
  sha256 "3c5770364366dfbf1ed02baeb572a7d69e3909db99d9476120286aa4c73d1b04"

  url "https://install.ottto.net/ottto-local-platform/releases/stable/#{version}/Ottto-macos-arm64.dmg"
  name "Ottto"
  desc "Local-first observability for AI coding agents (Claude Code, Codex, and more)"
  homepage "https://ottto.net/"

  livecheck do
    url "https://api.ottto.net/api/v1/local-platform/release"
    strategy :json do |json|
      json["latest_version"]
    end
  end

  auto_updates true
  depends_on arch: :arm64
  depends_on macos: :sonoma

  app "Ottto.app"

  uninstall launchctl: "net.ottto.service",
            quit:      "net.ottto.Companion"

  zap trash: [
    "~/Library/Application Support/Ottto",
    "~/Library/Caches/net.ottto.Companion",
    "~/Library/HTTPStorages/net.ottto.Companion",
    "~/Library/LaunchAgents/net.ottto.service.plist",
    "~/Library/Logs/Ottto",
    "~/Library/Preferences/net.ottto.Companion.plist",
    "~/Library/Saved Application State/net.ottto.Companion.savedState",
  ]
end
