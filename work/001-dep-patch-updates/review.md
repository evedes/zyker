# Review: Update tailwind, plug_crypto and elixir_make past GitHub's header limit

Reviewed code fingerprint: dfa5b9f940d3253b

## Verdict
pass: the lock moves exactly the three packages to versions that satisfy every requirement on them, cmake is safe to drop (lazy_html is the only native dep), and criteria 1–4 hold; criterion 5's Actions run is pending until the push.

## Findings
Blocking: none.

Acceptance criteria:
1. Pass. `mix.lock:9` elixir_make 0.10.1, `mix.lock:34` plug_crypto 2.2.1, `mix.lock:38`
   tailwind 0.5.2. The lock diff is three lines, only those entries. Inner/outer checksums are
   identical to zyker-cloud's `mix.lock`. Requirements on them still hold: tailwind `~> 0.3`
   (mix.exs), plug_crypto `~> 1.1.1 or ~> 1.2 or ~> 2.0` (plug), elixir_make `~> 0.9`
   (lazy_html) and `~> 0.7` (cc_precompiler). `mix.exs` is unchanged.
2. Pass (gate `mix hex.audit` exit 0).
3. Pass (gate `mix assets.setup` exit 0).
4. Pass (T01 NIF check exit 0). See the notes below on why that check proves it.
5. `ci.yaml:31` installs no cmake and keeps `build-essential git ca-certificates`. The
   GitHub Actions `ci` run is **pending** until the push, so it is not counted as a failure.

Dropping cmake is safe:
- Only `lazy_html` uses `:make` (`mix.lock:20`). Every other entry is `:mix` or `:rebar3`
  with pure Erlang (idna, telemetry, telemetry_poller). `fine` is header-only C++ that
  lazy_html uses. `cc_precompiler` and `elixir_make` are build tooling and don't build
  anything native themselves. cmake is used only by lazy_html's Makefile (the lexbor build),
  which runs only on the source fallback. `Dockerfile.dev` never installed cmake.

T01 NIF check, which is sound:
- elixir_make 0.10.1 (`lib/mix/tasks/compile.elixir_make.ex`) prints "Downloading precompiled
  NIF" only when the archive is missing from the cache dir. Every failure after that point
  (download, checksum, decompress) prints "Attempting to compile ... from source". If the
  target has no prebuilt NIF, it goes straight to the source build without printing the
  "Downloading" line, so the check fails then too. `deps.clean --build` deletes the
  `priv/liblazy_html.so` that would otherwise skip the whole path. The empty
  `ELIXIR_MAKE_CACHE_DIR` forces a real download. `$s` takes the exit status of the whole
  `&&` chain. So the check really proves the precompiled NIF was used, even on a host with
  cmake. The 0.10.1 downloader sets `max_header_size: 65_536` (`lib/elixir_make/downloader/httpc.ex:40`).

Non-blocking:
- Low. `.github/workflows/ci.yaml:41` and `work/001-dep-patch-updates/tickets/T02-ci-drop-cmake.md:26-27`:
  T02 says the new cache key makes the first run build `deps`/`_build` "afresh". But
  `restore-keys: mix-` restores the previous cache from the old lock. That cache includes
  `_build/test/lib/lazy_html/priv/liblazy_html.so`, which was built from source with cmake.
  elixir_make skips both the download and the build when that file exists. So unless Mix
  rebuilds lazy_html because elixir_make changed, a green first run may not exercise the NIF
  download at all. CI still can't break because of this: with no cmake, a rebuild that falls
  back to source fails loudly. But a green run is weaker evidence for criterion 5 than T02
  claims. When checking the run in ship, look for "Downloading precompiled NIF" in the
  `mix compile` step's log.
- Low. `work/001-dep-patch-updates/spec.md:29`: criterion 4 describes the check as
  `mix deps.compile lazy_html --force`. Run literally, that would not download anything,
  because `--force` leaves `priv/liblazy_html.so` in place and elixir_make returns early. T01
  correctly uses `mix deps.clean lazy_html --build` instead. This is a wording mismatch only,
  and the gate as run is the stronger one.
- Info. `work/flow.json` is also modified (`active` set to this feature). That is expected
  flow bookkeeping, not scope creep.
