defmodule LivePolls.PollsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `LivePolls.Polls` context.
  """

  @doc """
  Generate a poll.
  """
  def poll_fixture(attrs \\ %{}) do
    {:ok, poll} =
      attrs
      |> Enum.into(%{
        description: "some description",
        end_date: ~U[2024-10-01 19:54:00Z],
        title: "some title"
      })
      |> LivePolls.Polls.create_poll()

    poll
  end

  @doc """
  Generate a option.
  """
  def option_fixture(attrs \\ %{}) do
    {:ok, option} =
      attrs
      |> Enum.into(%{
        text: "some text",
        vote_count: 42
      })
      |> LivePolls.Polls.create_option()

    option
  end

  @doc """
  Generate a vote.
  """
  def vote_fixture(attrs \\ %{}) do
    {:ok, vote} =
      attrs
      |> Enum.into(%{

      })
      |> LivePolls.Polls.create_vote()

    vote
  end
end
