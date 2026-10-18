defmodule Zyker.Repo do
  use Ecto.Repo,
    otp_app: :zyker,
    adapter: Ecto.Adapters.Postgres
end
