defmodule Pokebbo.Repo do
  use Ecto.Repo,
    otp_app: :pokebbo,
    adapter: Ecto.Adapters.Postgres
end
