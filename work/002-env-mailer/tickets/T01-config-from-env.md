# T01: Add Zyker.Mailer.config_from_env/1

Inherits the standing Definition of Ready and Definition of Done from `work/STANDING.md`.

## Description / desired end state
`Zyker.Mailer.config_from_env/1` exists, takes the environment as a map of strings, and returns
the `Zyker.Mailer` config:
- `MAILER_ADAPTER` unset or `""` → `nil`;
- `resend` / `postmark` / `sendgrid` / `brevo` → `[adapter: Swoosh.Adapters.Resend |
  Postmark | Sendgrid | Brevo, api_key: <value of RESEND_API_KEY | POSTMARK_API_KEY |
  SENDGRID_API_KEY | BREVO_API_KEY>]`;
- a supported name whose key is unset or `""` → `ArgumentError` naming the key variable, e.g.
  `RESEND_API_KEY is missing; MAILER_ADAPTER=resend needs it`;
- any other value → `ArgumentError` naming the value and listing
  `resend, postmark, sendgrid, brevo`.

## Context / why
A deploy should choose its mail provider with environment variables, and host apps (zyker
doesn't load its own `config/*.exs` as a dependency) need the same logic as code they can call.
Implements spec.md "Behaviour" (first bullet) and acceptance criteria 1–4.

## Entry points
- `lib/zyker/mailer.ex`
- new test: `test/zyker/mailer_test.exs`

## In scope
The function, its `@doc`, and its tests.

## Out of scope
`config/*.exs` and README (T02), any adapter beyond the four, sending mail, zyker-cloud.

## Constraints / conventions
- Pure: it reads only the map it is given, so tests pass maps and never touch OS env
  (`async: true`).
- The supported adapters live in one module attribute (name → {adapter, key variable}), which
  also feeds the error message's list, in the table's order.
- Swoosh adapter modules are referenced as atoms; no new dependency.

## Reference example
zyker-cloud `config/runtime.exs` (the Resend block: an empty key counts as missing).

## Depends on
None.

## Gate
- Tests for acceptance criteria 1–4 exist, were seen failing before the code, and pass.
- Standing gates pass.

## Verification steps
```sh
mix test test/zyker/mailer_test.exs
```
