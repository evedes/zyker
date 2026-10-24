# T02: Stop installing cmake in CI

Inherits the standing Definition of Ready and Definition of Done from `work/STANDING.md`.

## Description / desired end state
The apt line in `.github/workflows/ci.yaml` installs `build-essential git ca-certificates`
without `cmake`; nothing else in the workflow changes. The GitHub Actions `ci` run for the
pushed commit succeeds, installing `lazy_html`'s precompiled NIF.

## Context / why
`cmake` was added in `0515b0e` only so `lazy_html` could build from source after its NIF
download failed. With `elixir_make` 0.10.1 (T01) the download works again; without `cmake` a
future download failure turns CI red instead of hiding behind a source build. Implements
spec.md "Behaviour" (last bullet) and acceptance criterion 5.

## Entry points
- `.github/workflows/ci.yaml`, the first `run:` step (apt-get)

## In scope
The `cmake` word on that apt line.

## Out of scope
Every other line of the workflow (no `hex.audit` or `assets.setup` steps), the Dockerfiles.

## Constraints / conventions
- The cache key is `mix-${{ hashFiles('mix.lock') }}`, so T01's lock change makes the first
  run build `deps`/`_build` afresh, which exercises the NIF download.

## Reference example
zyker-cloud's `.forgejo/workflows/deploy.yaml` `elixir` job: the same image without `cmake`.

## Depends on
T01.

## Gate
- `ci.yaml` mentions no `cmake` and still installs `build-essential git ca-certificates`.
- After the push, `gh run list` shows the `ci` run for HEAD as success (checked in ship).

## Verification steps
```sh
sh -c '! grep -q cmake .github/workflows/ci.yaml'
grep -q 'apt-get install -y --no-install-recommends build-essential git ca-certificates$' .github/workflows/ci.yaml
```
