defmodule EngageWeb.MemoryLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}
  alias Phoenix.LiveView.JS
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games.Memory
  alias Engage.Games.Memory.GameBoard
  alias Engage.Games.Chat
  alias Engage.Games.Chat.Message
  alias Engage.Helpers.Gravatar
  import EngageWeb.LiveHelpers
  alias EngageWeb.Util

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, user ->
        setup(socket, user)
      end)

    {:ok, socket}
  end

  def handle_params(%{"id" => game_code}, _uri, socket) do
    game_genserver_name = String.to_atom(game_code)
    chat_genserver_name = String.to_atom("chat_" <> game_code)
    Memory.GenServer.start(game_genserver_name)
    Chat.GenServer.start(chat_genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_code)
    Phoenix.PubSub.subscribe(Engage.PubSub, "chat_" <> game_code)

    players =
      Memory.GenServer.add_player(
        game_genserver_name,
        socket.assigns.player_id,
        socket.assigns.player_name
      )

    nth = Memory.GenServer.get_player_nth_by_name(game_genserver_name, socket.assigns.player_name)
    game_board = Memory.GenServer.view(game_genserver_name)
    messages = Chat.GenServer.view(chat_genserver_name)

    socket =
      if Memory.GenServer.game_started?(game_genserver_name) do
        assign(socket,
          nth: nth,
          game_code: game_code,
          players: players,
          game_board: game_board,
          messages: messages,
          game_genserver_name: game_genserver_name,
          chat_genserver_name: chat_genserver_name
        )
        |> scroll_chat()
      else
        route = "/game-lobby/memory/#{game_code}"
        push_redirect(socket, to: route)
      end

    {:noreply, socket}
  end

  def handle_event("make-move", %{"index" => index}, socket) do
    Memory.GenServer.make_move(
      socket.assigns.game_genserver_name,
      {socket.assigns.players[socket.assigns.nth], String.to_integer(index)}
    )

    {:noreply, socket}
  end

  def handle_event("send-message", %{"message-text" => text}, socket) do
    message = %Message{
      sender: socket.assigns.player_name,
      text: String.trim(text),
      avatar_src: socket.assigns.player_avatar
    }

    Chat.GenServer.send_message(
      socket.assigns.chat_genserver_name,
      message
    )

    socket =
      if String.trim(text) !== "" do
        clear_message_box(socket)
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("clipboard-insert", _, socket) do
    :timer.send_after(3500, :clear_flash)

    {:noreply,
     socket
     |> put_flash(:info, "Copied game code \"#{socket.assigns.game_code}\" to clipboard.")}
  end

  def handle_info(%GameBoard{} = game_board, socket) do
    {:noreply, assign(socket, game_board: game_board)}
  end

  def handle_info(players, socket) when is_map(players) do
    {:noreply, assign(socket, players: players)}
  end

  def handle_info(messages, socket) when is_list(messages) do
    socket =
      socket
      |> assign(messages: messages)
      |> scroll_chat()

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp setup(socket, user) do
    assign(socket,
      player_id: user.id,
      player_name: user.username,
      player_avatar: Gravatar.get_image_src_by_email(user.email, user.gravatar_style),
      game_board: %GameBoard{},
      players: %{first: nil, second: nil},
      messages: []
    )
  end

  defp card_front(board) do
    assigns = %{}
    classes = "area-full no-backface rotate-y-180"

    case board.card_skin do
      # not all skins have a special front

      _ ->
        ~H"""
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class={classes}>
        	<rect x=".5" y=".5" width="23" height="23" ry="1.92" fill-rule="evenodd" stroke-linecap="round" stroke-linejoin="round" class="fill-theme-2 dark-t:fill-theme-4 stroke-theme-3 dark-t:stroke-theme-5" />
        </svg>
        """
    end
  end

  defp card_back(board) do
    assigns = %{}
    classes = "area-full no-backface rotate-y-0"

    case board.card_skin do
      "stars" ->
        ~H"""
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class={classes}>
         <defs>
         	<linearGradient id="ta">
         		<stop stop-color="#e3dd24" offset="0" />
         		<stop stop-color="#e44e22" offset="1" />
         	</linearGradient>
         	<linearGradient id="tc" x1="23.5" x2=".5" y1=".5" y2="23.5" gradientUnits="userSpaceOnUse" xlink:href="#ta" />
         	<linearGradient id="tb" x1="19.1" x2="5.19" y1="4.38" y2="19.6" gradientUnits="userSpaceOnUse" xlink:href="#ta" />
         </defs>
         <rect x=".5" y=".5" width="23" height="23" ry="1.92" fill="#c4c6ca" fill-rule="evenodd" stroke="url(#tc)" stroke-linecap="round" stroke-linejoin="round" class="fill-[#f0f2f5] dark-t:fill-theme-3" />
         <path d="m5.19 17.4c0.89-0.445 1-0.89 1.34-2 0.334 1.11 0.445 1.56 1.34 2-0.89 0.445-1 0.89-1.34 2-0.334-1.11-0.445-1.56-1.34-2zm11.2-9.33c0.89-0.445 1-0.89 1.34-2 0.334 1.11 0.445 1.56 1.34 2-0.89 0.445-1 0.89-1.34 2-0.334-1.11-0.445-1.56-1.34-2zm-6.7 4.78c0.89-0.445 1-0.89 1.34-2 0.334 1.11 0.445 1.56 1.34 2-0.89 0.445-1 0.89-1.34 2-0.334-1.11-0.445-1.56-1.34-2zm-4.21-5.27c1.4-0.7 1.58-1.4 2.1-3.15 0.525 1.75 0.7 2.45 2.1 3.15-1.4 0.7-1.58 1.4-2.1 3.15-0.525-1.75-0.7-2.45-2.1-3.15zm7.64 8.05c1.77-0.887 2-1.77 2.66-3.99 0.665 2.22 0.887 3.11 2.66 3.99-1.77 0.887-2 1.77-2.66 3.99-0.666-2.22-0.887-3.11-2.66-3.99z" fill="none" stroke="url(#tb)" stroke-width=".667" />
        </svg>
        """

      "engage" ->
        ~H"""
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" class={classes}>
          <defs>
            <linearGradient id="ta">
              <stop stop-color="#9728e6" offset="0" />
              <stop stop-color="#eb7a4c" offset="1" />
            </linearGradient>
            <linearGradient id="tb" x1="4.58" x2="0" y1="2.71" y2="6.43" gradientTransform="matrix(2.17 0 0 2.17 6.49 2.82)" gradientUnits="userSpaceOnUse" xlink:href="#ta" />
            <linearGradient id="tc" x1="23.5" x2=".5" y1=".5" y2="23.5" gradientUnits="userSpaceOnUse" xlink:href="#ta" />
          </defs>
          <rect x=".5" y=".5" width="23" height="23" ry="1.92" fill-rule="evenodd" stroke="url(#tc)" stroke-linecap="round" stroke-linejoin="round" class="fill-[#f0f2f5] dark-t:fill-theme-3" />
          <path d="m12.9 7.22c-0.913 0-1.72 0.195-2.42 0.584-0.701 0.39-1.25 0.946-1.64 1.67-0.39 0.724-0.584 1.56-0.584 2.52 0 3.19-1.82 4.78-1.82 4.78h6.46c1.1 0 2.03-0.283 2.79-0.851 0.757-0.579 1.27-1.31 1.54-2.2h-2.52c-0.367 0.746-0.985 1.12-1.85 1.12-0.601 0-1.11-0.19-1.52-0.568-0.412-0.378-0.646-0.902-0.701-1.57h6.76c0.0445-0.267 0.0666-0.567 0.0666-0.901 0-0.902-0.195-1.7-0.584-2.39-0.378-0.701-0.918-1.24-1.62-1.62-0.69-0.378-1.48-0.568-2.35-0.568zm-0.0666 1.92c0.612 0 1.13 0.183 1.55 0.55 0.423 0.356 0.64 0.835 0.651 1.44h-4.39c0.0891-0.623 0.329-1.11 0.719-1.45 0.401-0.356 0.89-0.534 1.47-0.534z" fill="url(#tb)" />
        </svg>
        """

      _ ->
        ~H"""
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" font-family="Poppins" class={ "fill-theme-1 dark-t:fill-theme-5 " <> classes }>
          <rect x=".5" y=".5" width="23" height="23" ry="1.92" fill-rule="evenodd" stroke="url(#tc)" stroke-linecap="round" stroke-linejoin="round" class="fill-[#f0f2f5] dark-t:fill-theme-3 stroke-theme-2 dark-t:stroke-theme-4" />
          <text transform="rotate(19.5)" x="7.15" y="10.8" font-size="13px">?</text>
          <text transform="rotate(10.1)" x="17.4" y="13.9" font-size="8.33px">?</text>
          <text transform="rotate(-16.2)" x="3.26" y="23" font-size="9.72px">?</text>
          <text transform="rotate(-9.15)" x="12" y="10.4" font-size="7.17px">?</text>
        </svg>
        """
    end
  end

  defp player_indicator_classes(game_board, current, n) do
    if nths_turn?(game_board, n) do
      " -text-accent-600 -dark-t:text-accent-400 outline outline-2" <>
        if this_player?(current, n) do
          " outline-accent-600 dark-t:outline-accent-400 animate-pulse"
        else
          " outline-accent-500"
        end
    else
      " "
    end <>
      " px-3 py-1 rounded-md text-ellipsis transition-colors"
  end

  defp this_player?(current, n) do
    current === n
  end

  defp nths_turn?(game_board, n) do
    game_board.current_player === n
  end

  defp scroll_chat(socket) do
    push_event(socket, "scroll-end", %{id: "chat"})
  end

  defp clear_message_box(socket) do
    push_event(socket, "clear-input", %{id: "message-box"})
  end
end
