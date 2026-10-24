# T01: Update plug_crypto, tailwind and elixir_make in mix.lock

Inherits the standing Definition of Ready and Definition of Done from `work/STANDING.md`.

## Description / desired end state
`mix.lock` locks `plug_crypto` 2.2.1, `tailwind` 0.5.2 and `elixir_make` 0.10.1, and no other
locked dependency changes. `mix hex.audit` exits 0, `mix assets.setup` downloads the tailwind
binary, and `lazy_html` installs its downloaded precompiled NIF.

## Context / why
`plug_crypto` 2.2.0 carries EEF-CVE-2026-105963, and GitHub's release redirect now sends more
headers than Erlang's httpc accepts by default, which breaks the tailwind and `lazy_html` NIF
downloads in 0.5.1 and 0.10.0. Implements spec.md "Behaviour" (first three bullets) and
acceptance criteria 1–4.

## Entry points
- `mix.lock`, through `mix deps.update plug_crypto tailwind elixir_make`

## In scope
The `plug_crypto`, `tailwind` and `elixir_make` entries in `mix.lock`.

## Out of scope
`mix.exs`, every other locked dependency, the CI workflow (T02), zyker-cloud.

## Constraints / conventions
- `mix.exs` is unchanged: the versions fit `~> 0.3` (tailwind), plug's `~> 2.0` (plug_crypto)
  and lazy_html's `~> 0.9` (elixir_make).
- Check that the lock diff touches only those three entries.
- The NIF check cleans `lazy_html`'s build and uses an empty `ELIXIR_MAKE_CACHE_DIR`, so the
  download really happens, keeps mix's exit status, and fails on elixir_make's "Attempting to
  compile" fallback: this machine has `cmake`, so a source build would otherwise pass unnoticed.
  `lazy_html` is test-only, so the check sets `MIX_ENV=test` itself.

## Reference example
zyker-cloud `6395f0b` and `e5980e2`: the same three updates in cloud's lock.

## Depends on
None.

## Gate
- The three lock entries are at the new versions and nothing else in the lock changed.
- `mix hex.audit` exits 0, `mix assets.setup` succeeds, and the NIF check passes.
- Standing gates pass.

## Verification steps
```sh
grep -q '"plug_crypto": {:hex, :plug_crypto, "2.2.1"' mix.lock
grep -q '"tailwind": {:hex, :tailwind, "0.5.2"' mix.lock
grep -q '"elixir_make": {:hex, :elixir_make, "0.10.1"' mix.lock
mix hex.audit
mix assets.setup
sh -c 'export MIX_ENV=test; d=$(mktemp -d) && mix deps.clean lazy_html --build && ELIXIR_MAKE_CACHE_DIR=$d mix deps.compile lazy_html > $d/log 2>&1; s=$?; cat $d/log; [ $s = 0 ] && grep -q "Downloading precompiled" $d/log && ! grep -q "Attempting to compile" $d/log'
```
