defmodule LivePollsWeb.PollsNewLive do
  use LivePollsWeb, :live_view
  alias LivePolls.Polls
  alias LivePolls.Polls.Poll
  require Logger

  @durations [
    {"30 minutes", "30min"},
    {"1 hour", "1h"},
    {"2 hours", "2h"},
    {"3 hours", "3h"},
    {"5 hours", "5h"},
    {"1 day", "1d"},
    {"2 days", "2d"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       form: to_form(Polls.change_poll(%Poll{})),
       options: [],
       new_option: "",
       errors: %{}
     )}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    changeset =
      %Poll{}
      |> Polls.change_poll(poll_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("add_option", _params, socket) do
    options = socket.assigns.options ++ [""]
    {:noreply, assign(socket, options: options)}
  end

  @impl true
  def handle_event("remove_option", %{"index" => index}, socket) do
    index = String.to_integer(index)
    options = socket.assigns.options |> List.delete_at(index)
    {:noreply, assign(socket, options: options)}
  end

  @impl true
  def handle_event("update_option", %{"index" => index, "value" => value}, socket) do
    # update the option at the given index
    index = String.to_integer(index)
    options = socket.assigns.options |> List.replace_at(index, value)

    {:noreply, assign(socket, options: options)}
  end

  @impl true
  def handle_event("save", %{"poll" => poll_params}, socket) do
    socket = validate_options(socket)

    if Enum.any?(socket.assigns.errors, fn {_, v} -> v != nil end) do
      {:noreply, put_flash(socket, :error, "Please correct the errors in the options.")}
    else
      options =
        socket.assigns.options
        |> clean_options()

      end_date = poll_params["duration"] |> calculate_end_date()

      poll_params =
        poll_params
        |> Map.put("options", options)
        |> Map.put("end_date", end_date)
        |> Map.put("user_id", socket.assigns.current_user.id)

      Logger.info("Creating poll with params: #{inspect(poll_params)}")

      case Polls.create_poll(poll_params) do
        {:ok, _poll} ->
          {:noreply,
           socket
           |> put_flash(:info, "Poll created successfully")
           |> redirect(to: ~p"/")}

        {:error, %Ecto.Changeset{} = changeset} ->
          Logger.error("Failed to create poll: #{inspect(changeset)}")
          {:noreply, assign(socket, errors: changeset.errors)}
      end
    end
  end

  defp clean_options(options) do
    options
    |> Enum.map(&String.trim/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.uniq()
  end

  defp calculate_end_date(duration) do
    {value, unit} =
      case duration do
        "30min" -> {30, :minute}
        "1h" -> {1, :hour}
        "2h" -> {2, :hour}
        "3h" -> {3, :hour}
        "5h" -> {5, :hour}
        "1d" -> {1, :day}
        "2d" -> {2, :day}
      end

    DateTime.utc_now()
    |> DateTime.add(value, unit)
    |> DateTime.truncate(:second)
  end

  defp validate_options(socket) do
    options = socket.assigns.options

    errors =
      Enum.reduce(options, %{}, fn option, acc ->
        case validate_option_value(option) do
          {:error, error} ->
            Map.put(acc, option, error)

          {:ok, _} ->
            acc
        end
      end)

    errors =
      case validate_options_length(options) do
        {:error, error} ->
          Map.put(errors, "options", error)

        {:ok, _} ->
          errors
      end

    assign(socket, errors: errors)
  end

  defp validate_option_value(option) do
    if String.trim(option) == "" do
      {:error, "Option cannot be blank"}
    else
      {:ok, option}
    end
  end

  defp validate_options_length(options) do
    if length(options) < 2 do
      {:error, "At least 2 options are required"}
    else
      {:ok, options}
    end
  end

  defp durations, do: @durations

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-2xl mx-auto mt-8 p-6 bg-white rounded-lg shadow-md">
      <h2 class="text-2xl font-bold mb-6 text-gray-800">Create New Poll</h2>

      <.form for={@form} phx-change="validate" phx-submit="save" class="space-y-6" id="create_poll">
        <div>
          <.input
            field={@form[:title]}
            type="text"
            label="Title"
            placeholder="What are we voting on?"
            required
            class="w-full"
          />
        </div>

        <div>
          <.input
            field={@form[:description]}
            type="textarea"
            label="Description"
            placeholder="Optional description"
            class="w-full"
          />
        </div>

        <div>
          <label class="block text-sm font-medium text-gray-700 mb-2">Options</label>
          <%= for {option, index} <- Enum.with_index(@options) do %>
            <div class="flex flex-col mb-2">
              <div class="flex items-center space-x-2">
                <input
                  type="text"
                  name="poll[options][]"
                  value={option}
                  class={"flex-grow rounded-md shadow-sm focus:ring focus:ring-opacity-50 #{if @errors[option], do: "border-red-300 focus:border-red-300 focus:ring-red-200", else: "border-gray-300 focus:border-indigo-300 focus:ring-indigo-200"}"}
                  required
                  phx-keyup="update_option"
                  phx-value-index={index}
                />
                <%= if length(@options) > 1 do %>
                  <button
                    type="button"
                    phx-click="remove_option"
                    phx-value-index={index}
                    class="text-red-600 hover:text-red-800"
                  >
                    <svg
                      xmlns="http://www.w3.org/2000/svg"
                      class="h-5 w-5"
                      viewBox="0 0 20 20"
                      fill="currentColor"
                    >
                      <path
                        fill-rule="evenodd"
                        d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
                        clip-rule="evenodd"
                      />
                    </svg>
                  </button>
                <% end %>
              </div>
              <%= if @errors[option] do %>
                <p class="mt-1 text-sm text-red-600"><%= @errors[option] %></p>
              <% end %>
            </div>
          <% end %>
          <button
            type="button"
            phx-click="add_option"
            class="mt-2 inline-flex items-center px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-indigo-700 bg-indigo-100 hover:bg-indigo-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Add Option
          </button>
          <%= if @errors["options"] do %>
            <p class="mt-1 text-sm text-red-600"><%= @errors["options"] %></p>
          <% end %>
        </div>

        <div>
          <label for="duration" class="block text-sm font-medium text-gray-700 mb-2">Duration</label>
          <.input
            field={@form[:duration]}
            type="select"
            class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
            label="Duration"
            prompt="Select a duration"
            options={durations()}
            required
          />
          <%!-- <select
            id="duration"
            name="duration"
            class="mt-1 block w-full pl-3 pr-10 py-2 text-base border-gray-300 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm rounded-md"
            field={@form[:duration]}
          >
            <%= for duration <- ["30min", "1h", "2h", "3h", "5h", "1d", "2d"] do %>
              <option value={duration} selected={@duration == duration}><%= duration %></option>
            <% end %>
          </select> --%>
        </div>

        <div>
          <button
            type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500"
          >
            Create Poll
          </button>
        </div>
      </.form>
    </div>
    """
  end
end
