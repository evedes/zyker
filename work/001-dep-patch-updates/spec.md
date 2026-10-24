# Spec: Update tailwind, plug_crypto and elixir_make past GitHub's header limit

## Goal
A fresh zyker checkout can install its assets and test dependencies again, `mix hex.audit` is
clean, and CI goes back to installing `lazy_html`'s precompiled NIF instead of building it from
source with `cmake`.

## Behaviour
- `mix.lock` moves `plug_crypto` 2.2.0 → 2.2.1 (fixes EEF-CVE-2026-105963), `tailwind`
  0.5.1 → 0.5.2 and `elixir_make` 0.10.0 → 0.10.1 (both accept GitHub's oversized
  release-redirect headers). `mix.exs` is unchanged: all three fit its existing constraints.
- `mix assets.setup` downloads the tailwind binary instead of failing with
  `{:header_too_long, {:max, 10240}}`.
- `lazy_html` installs its precompiled NIF instead of falling back to a source build.
- `.github/workflows/ci.yaml` no longer installs `cmake`; the rest of its apt line and every
  step stay as they are.

## Data model
None.

## UI
None.

## Acceptance criteria
1. `mix.lock` locks `plug_crypto` 2.2.1, `tailwind` 0.5.2 and `elixir_make` 0.10.1, and no
   other locked dependency changes.
2. `mix hex.audit` exits 0.
3. `mix assets.setup` downloads tailwind.
4. With an empty `ELIXIR_MAKE_CACHE_DIR`, `mix deps.compile lazy_html --force` downloads the
   precompiled NIF and does not fall back to compiling from source.
5. `.github/workflows/ci.yaml` installs no `cmake`, and the GitHub Actions `ci` run for the
   pushed commit succeeds.

## Spec changes
None.

## Out of scope
- Any other dependency update, and any change to `mix.exs`.
- Adding `mix hex.audit` or `mix assets.setup` to CI.
- zyker-cloud (already updated in its own lock).
