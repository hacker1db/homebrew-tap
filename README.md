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

## Updates

Both formulas build from the same [ai-usage release](https://github.com/hacker1db/ai-usage/releases)
tarball, so they always move together. The `bump formulas` workflow
([`bump.yml`](.github/workflows/bump.yml)) points the `url` and `sha256` of both at the latest
release:

- **Immediately after a release.** ai-usage's `release` workflow sends a `repository_dispatch`
  (`ai-usage-release`) once it publishes. That needs the `TAP_DISPATCH_TOKEN` secret in
  hacker1db/ai-usage; see the "Releases" section of its README for the exact, single-repository
  token setup. Nothing is configured in this repository for it.
- **Every six hours** as a fallback, and on demand from the Actions tab (Run workflow).

Each run takes the latest release from the GitHub API (the dispatch payload is only a hint), checks
the tarball contains both commands, and rewrites the formulas with
[`scripts/update-formulas.sh`](scripts/update-formulas.sh). Runs are serialized; a version that is
not newer than the formulas' is a no-op, so repeats and late dispatches never downgrade. The
commit goes through the GitHub API, so GitHub signs it, and only lands if `main` has not moved since
the run read it (it refetches and retries otherwise).

`scripts/test-update-formulas.sh` covers the updater, including malformed tags and checksums,
downgrades, formulas that disagree, and formulas whose `url` or `sha256` line it does not recognise.
