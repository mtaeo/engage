defmodule EngageWeb.ConnectFourLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}
  import EngageWeb.LiveHelpers
  alias Phoenix.LiveView.JS
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games.ConnectFour
  alias Engage.Games.ConnectFour.GameBoard
  alias Engage.Games.Chat
  alias Engage.Games.Chat.Message
  alias Engage.Helpers.Gravatar
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
    ConnectFour.GenServer.start(game_genserver_name)
    Chat.GenServer.start(chat_genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_code)
    Phoenix.PubSub.subscribe(Engage.PubSub, "chat_" <> game_code)

    players =
      ConnectFour.GenServer.add_player(
        game_genserver_name,
        socket.assigns.player_id,
        socket.assigns.player_name
      )

    nth =
      ConnectFour.GenServer.get_player_nth_by_name(
        game_genserver_name,
        socket.assigns.player_name
      )

    game_board = ConnectFour.GenServer.view(game_genserver_name)
    messages = Chat.GenServer.view(chat_genserver_name)

    socket =
      if ConnectFour.GenServer.game_started?(game_genserver_name) do
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
        route = "/game-lobby/connect-four/#{game_code}"
        push_redirect(socket, to: route)
      end

    {:noreply, socket}
  end

  def handle_event("make-move", %{"column" => col}, socket) do
    ConnectFour.GenServer.make_move(
      socket.assigns.game_genserver_name,
      {socket.assigns.players[socket.assigns.nth], String.to_integer(col)}
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

  def player_color(nth) do
    case nth do
      :first ->
        "bg-red-600"

      :second ->
        "bg-yellow-500"

      _ ->
        ""
    end
  end

  defp get_rows_for_column(board_state, col) do
    board_state
    |> Stream.drop(col)
    |> Stream.take_every(7)
    |> Enum.map(fn {index, player} ->
      row = div(index - col, 7)
      {row, player}
    end)
  end

  defp rounded_corners(col, row) do
    cond do
      col === 0 and row === 0 -> "rounded-tl-2xl"
      col === 6 and row === 0 -> "rounded-tr-2xl"
      col === 0 and row === 5 -> "rounded-bl-2xl"
      col === 6 and row === 5 -> "rounded-br-2xl"
      true -> ""
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
