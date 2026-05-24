# Ottto Homebrew Tap

Homebrew tap for the stable Ottto CLI and per-user local service.

```bash
brew tap ottto-ai/tap
brew install ottto
brew services start ottto
ottto --no-autostart status --json
```

This tap pins immutable stable release artifacts from `https://install.ottto.net/ottto-local-platform/releases/stable/<version>/`. Update `Formula/ottto.rb` only from a signed, notarized, Gatekeeper-accepted stable release manifest after clean Homebrew install QA passes.
