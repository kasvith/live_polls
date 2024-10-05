defmodule LivePolls.Polls.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do

    field :user_id, :id
    field :option_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> cast(attrs, [])
    |> validate_required([])
  end
end
