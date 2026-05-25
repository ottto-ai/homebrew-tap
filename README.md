# Ottto Homebrew Tap

Homebrew tap for the stable Ottto CLI and per-user local service.

```bash
brew tap ottto-ai/tap
brew install ottto
brew services start ottto
ottto --no-autostart status --json
```

This tap pins immutable stable release artifacts from `https://install.ottto.net/ottto-local-platform/releases/stable/<version>/`. Update `Formula/ottto.rb` only from a signed, notarized, Gatekeeper-accepted stable release manifest after clean Homebrew install QA passes.

## Service Lifecycle

Homebrew owns the per-user `net.ottto.service` launchd job for this install
path. Use `brew services restart ottto` after upgrading so launchd points at
the current Homebrew opt path:

```bash
brew update
brew upgrade ottto
brew services restart ottto
```

If `/Applications/Ottto.app` is also installed, leave service lifecycle with
Homebrew. The app should connect to the Homebrew-owned service and should not
replace the Homebrew LaunchAgent. To switch away from Homebrew ownership, stop
or uninstall the formula first, then use the app-bundle install path as the
owner.
