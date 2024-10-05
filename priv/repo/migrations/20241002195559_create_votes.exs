defmodule LivePolls.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :user_id, references(:users, on_delete: :nothing)
      add :option_id, references(:options, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:user_id])
    create index(:votes, [:option_id])
  end
end
