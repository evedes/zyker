defmodule Zyker.RuntimeConfigTest do
  # Sets OS environment variables, so not async.
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @prod_env %{
    "DATABASE_URL" => "ecto://user:pass@localhost/zyker",
    "SECRET_KEY_BASE" => String.duplicate("a", 64),
    "MAILER_ADAPTER" => "resend",
    "RESEND_API_KEY" => "re_x"
  }

  setup do
    previous = Map.new(@prod_env, fn {name, _} -> {name, System.get_env(name)} end)
    System.put_env(@prod_env)

    on_exit(fn ->
      Enum.each(previous, fn
        {name, nil} -> System.delete_env(name)
        {name, value} -> System.put_env(name, value)
      end)
    end)
  end

  defp read_prod, do: Config.Reader.read!("config/runtime.exs", env: :prod)

  describe "prod mailer" do
    test "comes from MAILER_ADAPTER and the provider's key" do
      mailer = read_prod()[:zyker][Zyker.Mailer]

      assert mailer[:adapter] == Swoosh.Adapters.Resend
      assert mailer[:api_key] == "re_x"
    end

    test "is left alone, with a warning, without MAILER_ADAPTER" do
      System.delete_env("MAILER_ADAPTER")

      stderr = capture_io(:stderr, fn -> send(self(), {:config, read_prod()}) end)

      assert_received {:config, config}
      refute Keyword.has_key?(config[:zyker], Zyker.Mailer)

      assert stderr =~
               "warning: MAILER_ADAPTER is not set; zyker will not deliver email " <>
                 "(supported: resend, postmark, sendgrid, brevo)"
    end
  end

  test "the test mailer is still Swoosh.Adapters.Test" do
    assert Application.get_env(:zyker, Zyker.Mailer)[:adapter] == Swoosh.Adapters.Test
  end
end
