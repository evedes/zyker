defmodule Zyker.Mailer do
  use Swoosh.Mailer, otp_app: :zyker

  # MAILER_ADAPTER value => {Swoosh adapter, the variable holding its API key}
  @adapters [
    {"resend", Swoosh.Adapters.Resend, "RESEND_API_KEY"},
    {"postmark", Swoosh.Adapters.Postmark, "POSTMARK_API_KEY"},
    {"sendgrid", Swoosh.Adapters.Sendgrid, "SENDGRID_API_KEY"},
    {"brevo", Swoosh.Adapters.Brevo, "BREVO_API_KEY"}
  ]

  @doc """
  The `MAILER_ADAPTER` values `config_from_env/1` supports.
  """
  def adapter_names, do: Enum.map(@adapters, &elem(&1, 0))

  @doc """
  The mailer config `env` (a map such as `System.get_env()`) asks for, or `nil` when
  `MAILER_ADAPTER` is unset or empty.

  `MAILER_ADAPTER` names the adapter (see `adapter_names/0`) and the provider's own variable
  holds its key, e.g. `MAILER_ADAPTER=resend` with `RESEND_API_KEY`. Raises `ArgumentError`
  on an unsupported adapter or a missing key. Meant for `config/runtime.exs`:

      if config = Zyker.Mailer.config_from_env(System.get_env()) do
        config :zyker, Zyker.Mailer, config
      end
  """
  def config_from_env(env) do
    case Map.get(env, "MAILER_ADAPTER", "") do
      "" -> nil
      name -> adapter_config(name, env)
    end
  end

  defp adapter_config(name, env) do
    case List.keyfind(@adapters, name, 0) do
      {^name, adapter, key_var} ->
        case Map.get(env, key_var, "") do
          "" -> raise ArgumentError, "#{key_var} is missing; MAILER_ADAPTER=#{name} needs it"
          key -> [adapter: adapter, api_key: key]
        end

      nil ->
        raise ArgumentError,
              "MAILER_ADAPTER=#{inspect(name)} is not supported; use one of: " <>
                Enum.join(adapter_names(), ", ")
    end
  end
end
