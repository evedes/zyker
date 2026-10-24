# Spec: Configure the production mailer from environment variables

## Goal
A zyker deployment picks its mail provider with environment variables instead of edited config:
`MAILER_ADAPTER=resend` plus `RESEND_API_KEY` is enough. The same code is available to host apps
that run zyker as a dependency (zyker-cloud), whose own `config/runtime.exs` calls it. A deploy
that sets nothing keeps booting as today, with a warning that mail goes nowhere.

## Behaviour
- `Zyker.Mailer.config_from_env(env)` takes the environment as a map of strings (callers pass
  `System.get_env()`) and returns the `Zyker.Mailer` config for it:
  - `MAILER_ADAPTER` unset or empty → `nil` (nothing configured).
  - `MAILER_ADAPTER` set to one of the supported names → `[adapter: <module>, api_key: <key>]`,
    the key read from that provider's variable:

    | `MAILER_ADAPTER` | adapter                    | key variable       |
    |------------------|----------------------------|--------------------|
    | `resend`         | `Swoosh.Adapters.Resend`   | `RESEND_API_KEY`   |
    | `postmark`       | `Swoosh.Adapters.Postmark` | `POSTMARK_API_KEY` |
    | `sendgrid`       | `Swoosh.Adapters.Sendgrid` | `SENDGRID_API_KEY` |
    | `brevo`          | `Swoosh.Adapters.Brevo`    | `BREVO_API_KEY`    |

  - A supported adapter whose key variable is unset or empty → raises `ArgumentError` naming
    the variable (e.g. `RESEND_API_KEY is missing; MAILER_ADAPTER=resend needs it`).
  - Any other `MAILER_ADAPTER` value → raises `ArgumentError` that names the value and lists
    the supported names. Names are matched exactly (lowercase).
- zyker's `config/runtime.exs` prod block calls it with `System.get_env()`. With a config, it sets
  `config :zyker, Zyker.Mailer, <config>`. With `nil`, it leaves the Local adapter from
  `config/config.exs` in place and prints to stderr, once at boot:
  `warning: MAILER_ADAPTER is not set; zyker will not deliver email (supported: resend, postmark, sendgrid, brevo)`.
  The commented Mailgun example goes.
- A raise in the function makes the release fail to boot, with the message above.
- Dev and test are unchanged (`Swoosh.Adapters.Local` / `Swoosh.Adapters.Test`); prod keeps
  `api_client: Swoosh.ApiClient.Req` from `config/prod.exs`.
- README documents the variables in a short mail section, and the "extending" section says host
  apps call `Zyker.Mailer.config_from_env/1` from their own `config/runtime.exs`.

## Data model
None.

## UI
None.

## Acceptance criteria
1. For each of the four names, `config_from_env/1` with `MAILER_ADAPTER` and the matching key
   set returns `[adapter: <module>, api_key: <key>]`.
2. With `MAILER_ADAPTER` unset, or set to `""`, it returns `nil`.
3. With a supported `MAILER_ADAPTER` and its key unset or `""`, it raises `ArgumentError` whose
   message names the key variable.
4. With `MAILER_ADAPTER=mailgun` (or any unsupported value), it raises `ArgumentError` whose
   message names the value and lists `resend, postmark, sendgrid, brevo`.
5. Reading `config/runtime.exs` for `:prod` (with `DATABASE_URL` and `SECRET_KEY_BASE` set) and
   `MAILER_ADAPTER=resend`, `RESEND_API_KEY=re_x` yields `Zyker.Mailer` config with
   `adapter: Swoosh.Adapters.Resend, api_key: "re_x"`; without `MAILER_ADAPTER` it sets no
   `Zyker.Mailer` config and prints the warning.
6. The test env's mailer is still `Swoosh.Adapters.Test`.

## Spec changes
None.

## Out of scope
- SMTP, Mailgun and any adapter that needs a new dependency or more than an API key.
- Sender address, templates, or sending any mail (nothing in zyker sends mail yet).
- Switching zyker-cloud to the function (a follow-up zyker-cloud feature).
- Changing dev or test mailers.
