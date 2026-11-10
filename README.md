# homebrew-tap

Homebrew formulas for hacker1db tools.

```zsh
brew tap hacker1db/tap
brew install ai-usage foundry-entra-proxy
```

| Formula | Source |
| --- | --- |
| `ai-usage` | [hacker1db/ai-usage](https://github.com/hacker1db/ai-usage) dashboard, TUI, and reports |
| `foundry-entra-proxy` | the Foundry Entra proxy from the same repo |

Both build from source with Go. Add `--HEAD` to build from `main`.

The `bump formulas` workflow checks every six hours for a newer ai-usage release and updates
the `url` and `sha256` in both formulas.
