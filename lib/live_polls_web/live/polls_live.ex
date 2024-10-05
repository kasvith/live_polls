defmodule LivePollsWeb.PollsLive do
  alias LivePolls.Polls
  use LivePollsWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    Polls.subscribe_to_new_polls()
    polls = Polls.list_active_polls()

    {:ok, assign(socket, polls: polls)}
  end

  @impl true
  def handle_info(%{topic: "new_poll", payload: state}, socket) do
    IO.inspect("Received message from topic: #{inspect(state)}")
    {:noreply, socket}
  end

  @impl true
  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <section class="mb-12">
      <h1 class="text-5xl font-bold text-center p-4">🗳️ Live Polls</h1>
      <h2 class="text-2xl text-center text-gray-500 p-1">
        Create and share live polls with your audience in real-time 🚀
      </h2>
    </section>
    <div class="max-w-2xl mx-auto px-4">
      <div class="space-y-6">
        <%= for poll <- @polls do %>
          <div class="bg-white p-6 rounded-lg shadow-sm hover:shadow-md transition duration-300">
            <div class="flex flex-col sm:flex-row justify-between items-start">
              <div class="flex-grow pr-4 mb-4 sm:mb-0">
                <h2 class="text-xl font-medium text-gray-900 mb-2"><%= poll.title %></h2>
                <p class="text-sm text-gray-600 mb-2"><%= poll.description %></p>
                <span class="text-sm text-gray-500">
                  🗳️ <%= poll.total_votes %> <%= if poll.total_votes == 1, do: "vote", else: "votes" %>
                </span>
              </div>
              <.link class="w-full sm:w-auto px-6 py-2 bg-orange-400 text-white text-base font-medium rounded-md hover:bg-orange-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-150 ease-in-out transform hover:scale-105 shadow-md">
                Vote
              </.link>
            </div>
          </div>
        <% end %>

        <%= if length(@polls) == 0 do %>
          <div class="text-center text-gray-500">No active polls available.</div>
        <% end %>
      </div>
      <div class="mt-10 text-center">
        <.link
          navigate={~p"/polls/new"}
          class="inline-block px-6 py-3 bg-green-500 text-white text-base font-medium rounded-md hover:bg-green-600 transition duration-150 ease-in-out transform hover:scale-105 shadow-md"
        >
          Create New Poll
        </.link>
      </div>
    </div>
    """
  end
end
