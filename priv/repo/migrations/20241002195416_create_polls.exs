defmodule LivePolls.Repo.Migrations.CreatePolls do
  use Ecto.Migration

  def change do
    create table(:polls) do
      add :title, :string
      add :description, :text
      add :end_date, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)
      add :short_id, :text

      timestamps(type: :utc_datetime)
    end

    create index(:polls, [:user_id])
    create index(:polls, [:short_id], unique: true)
  end
end
