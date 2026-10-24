defmodule Zyker.MailerTest do
  use ExUnit.Case, async: true

  alias Zyker.Mailer

  describe "config_from_env/1" do
    test "configures each supported adapter with its provider's key" do
      for {name, adapter, key} <- [
            {"resend", Swoosh.Adapters.Resend, "RESEND_API_KEY"},
            {"postmark", Swoosh.Adapters.Postmark, "POSTMARK_API_KEY"},
            {"sendgrid", Swoosh.Adapters.Sendgrid, "SENDGRID_API_KEY"},
            {"brevo", Swoosh.Adapters.Brevo, "BREVO_API_KEY"}
          ] do
        env = %{"MAILER_ADAPTER" => name, key => "secret-#{name}"}

        assert Mailer.config_from_env(env) == [adapter: adapter, api_key: "secret-#{name}"]
      end
    end

    test "configures nothing without MAILER_ADAPTER" do
      assert Mailer.config_from_env(%{}) == nil
      assert Mailer.config_from_env(%{"MAILER_ADAPTER" => ""}) == nil
    end

    test "raises when the adapter's key is missing or empty" do
      for env <- [
            %{"MAILER_ADAPTER" => "resend"},
            %{"MAILER_ADAPTER" => "resend", "RESEND_API_KEY" => ""}
          ] do
        assert_raise ArgumentError,
                     ~r/RESEND_API_KEY is missing; MAILER_ADAPTER=resend needs it/,
                     fn ->
                       Mailer.config_from_env(env)
                     end
      end
    end

    test "raises on an unsupported adapter, listing the supported ones" do
      error =
        assert_raise ArgumentError, fn ->
          Mailer.config_from_env(%{"MAILER_ADAPTER" => "mailgun"})
        end

      assert error.message =~ ~s("mailgun")
      assert error.message =~ "resend, postmark, sendgrid, brevo"
    end
  end
end
