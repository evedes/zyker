# Research: Configure the production mailer from environment variables

## Question
In prod, zyker's mailer stays on `Swoosh.Adapters.Local` (`config/config.exs`) unless the
deployer edits config: `config/runtime.exs` only carries a commented Mailgun example. zyker-cloud
had to write its own Resend block (zyker-cloud `config/runtime.exs`, feature 002-resend-mailer).
What generic, env-driven mailer configuration should zyker offer so a self-hoster sets
environment variables instead of editing config, and so cloud can use the same code?

## Findings
- `Zyker.Mailer` (`lib/zyker/mailer.ex`) is `use Swoosh.Mailer, otp_app: :zyker`. Nothing sends
  mail yet.
- Config today: `config/config.exs` sets `Swoosh.Adapters.Local`; `config/test.exs` sets
  `Swoosh.Adapters.Test`; `config/prod.exs` sets `api_client: Swoosh.ApiClient.Req` and
  `local: false`; dev and test disable the API client. `req` is a direct dependency.
- **zyker's `config/*.exs` is not loaded when zyker is a dependency** (zyker-cloud's AGENTS.md):
  cloud configures `:zyker` itself. So a block in zyker's `config/runtime.exs` alone would not
  reach cloud: the generic part has to be code in zyker (a function both `runtime.exs` files
  call), not only config.
- Calling a dependency's module from `config/runtime.exs` works: runtime config is evaluated
  after compilation under Mix, and after the code paths are loaded in a release.
- Swoosh 1.29 adapters and what they need:
  - API key only, over the Req client zyker already has: `Resend`, `Postmark`, `Sendgrid`,
    `Brevo` (`required_config: [:api_key]`).
  - `Mailgun`: `api_key` and `domain`, plus the `multipart` dependency zyker does not have.
  - `SMTP`: `relay` (plus username, password, port, TLS), plus the `gen_smtp` dependency.
- Prior art: zyker-cloud reads `RESEND_API_KEY` and raises when it is missing; schola and rhizo
  do the same. The variable names follow each provider (`RESEND_API_KEY`).

## Options
Mechanism:
1. **A function in zyker** (e.g. `Zyker.Mailer.config_from_env/1`, taking the env as a map and
   returning the mailer keyword list, raising on missing or unknown values), called from zyker's
   `config/runtime.exs` prod block, and from cloud's once cloud switches to it. Pure, so it is
   tested directly, without touching OS env. Recommended.
2. **zyker reads the env at application start** and puts the mailer config itself: cloud gets it
   without touching its config, but config then changes behind the app's back and is harder to
   reason about or override.

Variable names:
- `MAILER_ADAPTER` (e.g. `resend`) chooses the adapter; the key uses the provider's own name
  (`RESEND_API_KEY`, `POSTMARK_API_KEY`, ...), matching the prior art and cloud's existing secret.

## Open questions
- [x] Which adapters? The four API-key ones that need no new dependency: Resend, Postmark,
      SendGrid and Brevo. No SMTP, no Mailgun.
- [x] With `MAILER_ADAPTER` unset in prod? Keep the Local adapter so existing deploys keep
      booting, and print a warning at boot that mail goes nowhere.
- [x] Mechanism and names? As recommended: a function (`Zyker.Mailer.config_from_env/1`),
      `MAILER_ADAPTER`, and provider key names.
- [x] Cloud? Yes: a follow-up zyker-cloud feature switches cloud to the function.
