defmodule Engage.Repo do
  use Ecto.Repo,
    otp_app: :engage,
    adapter: Ecto.Adapters.Postgres
end
