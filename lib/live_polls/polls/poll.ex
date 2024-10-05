defmodule LivePolls.Polls.Poll do
  alias LivePolls.Polls.Option
  use Ecto.Schema
  import Ecto.Changeset

  schema "polls" do
    field :description, :string
    field :short_id, :string
    field :title, :string
    field :end_date, :utc_datetime

    belongs_to :user, LivePolls.Accounts.User
    has_many :options, LivePolls.Polls.Option
    has_many :votes, through: [:options, :votes]

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(poll, attrs) do
    poll
    |> cast(attrs, [:title, :description, :end_date, :user_id])
    |> validate_required([:title, :end_date, :user_id])
    |> cast_assoc(:options, with: &Option.changeset/2)
    |> put_change(:short_id, generate_short_id())
  end

  defp generate_short_id do
    # generate a url safe short id

    Nanoid.generate(10)
  end
end
