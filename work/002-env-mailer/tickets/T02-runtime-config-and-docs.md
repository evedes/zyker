# T02: Use config_from_env in prod runtime config, and document it

Inherits the standing Definition of Ready and Definition of Done from `work/STANDING.md`.

## Description / desired end state
- The prod block of `config/runtime.exs` replaces the commented Mailgun example with a call to
  `Zyker.Mailer.config_from_env(System.get_env())`: a config is applied with
  `config :zyker, Zyker.Mailer, ...`; `nil` leaves the Local adapter from `config/config.exs`
  and prints to stderr
  `warning: MAILER_ADAPTER is not set; zyker will not deliver email (supported: resend, postmark, sendgrid, brevo)`.
- README gets a short mail section listing `MAILER_ADAPTER` and the four key variables, and the
  "extending" section says host apps call `Zyker.Mailer.config_from_env/1` from their own
  `config/runtime.exs`.

## Context / why
Wires T01 into zyker's own releases and tells self-hosters and host apps how to use it.
Implements spec.md "Behaviour" (bullets 2–5) and acceptance criteria 5–6.

## Entry points
- `config/runtime.exs` (prod block, "Configuring the mailer" comment)
- `README.md`
- new test: `test/zyker/runtime_config_test.exs`

## In scope
The prod mailer lines in `config/runtime.exs`, the README sections, the test.

## Out of scope
`config/config.exs`, `dev.exs`, `test.exs`, `prod.exs`; `lib/` (T01); zyker-cloud.

## Constraints / conventions
- The warning's text comes from one place; if T01 exposes the supported names (e.g.
  `Zyker.Mailer.adapters/0`), the warning uses it rather than repeating the list.
- The test reads the file with `Config.Reader.read!("config/runtime.exs", env: :prod)`, with
  `DATABASE_URL`, `SECRET_KEY_BASE`, `MAILER_ADAPTER` and `RESEND_API_KEY` set via
  `System.put_env/2` and restored in `on_exit` (`async: false`), and captures stderr with
  `ExUnit.CaptureIO`.
- README keeps its existing tone and `## \`> section\`` heading style.

## Reference example
zyker-cloud `test/zyker_cloud/runtime_config_test.exs`: the same Config.Reader test shape.

## Depends on
T01.

## Gate
- Tests for acceptance criteria 5–6 exist, were seen failing before the change, and pass.
- README mentions `MAILER_ADAPTER` and `config_from_env`.
- Standing gates pass.

## Verification steps
```sh
mix test test/zyker/runtime_config_test.exs
grep -q 'Zyker.Mailer.config_from_env(System.get_env())' config/runtime.exs
grep -q 'MAILER_ADAPTER' README.md
grep -q 'config_from_env' README.md
```
