defmodule LivePollsWeb.Nav do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(_, _params, _session, socket) do
    socket =
      attach_hook(
        socket,
        :path_hook,
        :handle_params,
        fn _params, uri, socket -> {:cont, assign(socket, :current_url, URI.new!(uri).path)} end
      )

    {:cont, socket}
  end
end
