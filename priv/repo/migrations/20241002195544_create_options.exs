defmodule LivePolls.Repo.Migrations.CreateOptions do
  use Ecto.Migration

  def change do
    create table(:options) do
      add :text, :string
      add :vote_count, :integer
      add :poll_id, references(:polls, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:options, [:poll_id])
  end
end
