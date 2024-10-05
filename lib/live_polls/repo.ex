defmodule LivePolls.Repo do
  use Ecto.Repo,
    otp_app: :live_polls,
    adapter: Ecto.Adapters.Postgres
end
