defmodule LivePolls.Polls.Option do
  use Ecto.Schema
  import Ecto.Changeset

  schema "options" do
    field :text, :string
    field :vote_count, :integer
    field :poll_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(option, attrs) do
    # if the option is a binary, it means it's a new option with text
    option
    |> cast(attrs, [:text])
    |> validate_required([:text])
  end
end
