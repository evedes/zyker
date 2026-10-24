# Research: Update tailwind, plug_crypto and elixir_make past GitHub's header limit

## Question
zyker-cloud's CI broke on 2026-10-24 on three locked dependencies that zyker itself uses, and
cloud fixed them in its own `mix.lock` (zyker-cloud `6395f0b`, `e5980e2`). zyker's `mix.lock`
still has the old versions. What does zyker need, and can its CI drop the `cmake` workaround
added for the same failure?

## Findings
- zyker locks `plug_crypto` 2.2.0, `tailwind` 0.5.1 and `elixir_make` 0.10.0 (`mix.lock`).
  `mix.exs` asks for `{:tailwind, "~> 0.3"}` and `{:lazy_html, ">= 0.1.0", only: :test}`;
  `plug_crypto` (through plug, `~> 2.0`) and `elixir_make` (through lazy_html `~> 0.9`) are
  transitive.
- `plug_crypto` 2.2.0 has advisory EEF-CVE-2026-105963 (MEDIUM, secret key base exposed in
  stack trace arguments); `mix hex.audit` fails on it. 2.2.1 (2026-10-23) fixes it.
- GitHub's release-download redirect now sends about 10.8 KB of headers, over the 10240-byte
  limit Erlang's httpc applies by default. Two dependencies download from GitHub through it:
  - `tailwind` 0.5.1: `mix assets.setup` (`tailwind.install`) fails with
    `{:header_too_long, {:max, 10240}}`, so a fresh checkout cannot build assets. 0.5.2
    (2026-10-24): "Allow larger response headers when downloading Tailwind".
  - `elixir_make` 0.10.0: `lazy_html`'s precompiled NIF download fails, reported as
    `:enoent`, and it falls back to building lexbor from source, which needs `cmake`. 0.10.1
    (2026-10-24): "Increase max header length".
- `.github/workflows/ci.yaml` installs `cmake` (commit `0515b0e`, "build lazy_html from source
  with cmake") as the workaround for that download failure. CI is green with it; it runs neither
  `mix hex.audit` nor `mix assets.setup`, so it doesn't see the other two problems.
- Prior art: zyker-cloud's lock has all three versions; its CI (the same Elixir/OTP image,
  without `cmake`) installs the precompiled NIF and passes `hex.audit`.
- `deps/` and `_build/` are the dev stack's Docker volumes (root-owned on the host), so host-side
  gates need `MIX_DEPS_PATH`/`MIX_BUILD_PATH` pointing elsewhere.

## Options
1. **Update the three in `mix.lock` and drop `cmake` from CI**: CI goes back to the precompiled
   NIF, which proves the fix and keeps CI quick; a later download failure shows up as a red
   build instead of a silent source build.
2. **Update the three and keep `cmake`**: a safety net, but it hides the next download failure,
   which is how the header issue went unnoticed here.
3. **Update only `plug_crypto`** (the security fix): leaves fresh checkouts unable to run
   `mix assets.setup`.

Recommendation: option 1.

## Open questions
- [x] None. Removing `cmake` is part of option 1; the user can say so if they want to keep it.
