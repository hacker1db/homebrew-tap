# homebrew-tap

```zsh
brew install hacker1db/tap/jxscout-rs
```

| Formula | Source | Notes |
| --- | --- | --- |
| `jxscout-rs` | [hacker1db/jxscout-rs](https://github.com/hacker1db/jxscout-rs) | Prebuilt release binaries (macOS arm64/x86_64, Linux musl arm64/x86_64). `bump-jxscout-rs.yml` polls for new releases and opens a bump PR. |

The ai-usage and foundry-entra-proxy formulas now live in the
[ai-usage](https://github.com/hacker1db/ai-usage) repo under `Formula/`:

```zsh
brew tap hacker1db/ai-usage https://github.com/hacker1db/ai-usage
brew install hacker1db/ai-usage/ai-usage hacker1db/ai-usage/foundry-entra-proxy
```
