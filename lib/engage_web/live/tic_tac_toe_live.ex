defmodule EngageWeb.TicTacToeLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}
  alias Phoenix.LiveView.JS
  alias Engage.Games.Generic.Coordinate
  alias Engage.Games.TicTacToe
  alias Engage.Games.TicTacToe.GameBoard
  alias Engage.Games.Chat
  alias Engage.Games.Chat.Message
  alias Engage.Helpers.Gravatar
  import EngageWeb.LiveHelpers
  alias EngageWeb.Router.Helpers, as: Routes
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
    TicTacToe.GenServer.start(game_genserver_name)
    Chat.GenServer.start(chat_genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_code)
    Phoenix.PubSub.subscribe(Engage.PubSub, "chat_" <> game_code)

    players =
      TicTacToe.GenServer.add_player(
        game_genserver_name,
        socket.assigns.player_id,
        socket.assigns.player_name
      )

    nth =
      TicTacToe.GenServer.get_player_nth_by_name(game_genserver_name, socket.assigns.player_name)

    game_board = TicTacToe.GenServer.view(game_genserver_name)
    messages = Chat.GenServer.view(chat_genserver_name)

    socket =
      if TicTacToe.GenServer.game_started?(game_genserver_name) do
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
        route = "/game-lobby/tic-tac-toe/#{game_code}"
        push_redirect(socket, to: route)
      end

    {:noreply, socket}
  end

  def handle_event("make-move", %{"coordinate-x" => x, "coordinate-y" => y}, socket) do
    coordinate = get_coordinate(x, y)

    TicTacToe.GenServer.make_move(
      socket.assigns.game_genserver_name,
      {socket.assigns.players[socket.assigns.nth], coordinate}
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

  defp get_coordinate(x, y) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)
    %Coordinate{x: x, y: y}
  end

  defp cell_content(players, symbol) do
    case symbol do
      :x ->
        get_skin(:x, players.first)

      :o ->
        get_skin(:o, players.second)

      _ ->
        ""
    end
  end

  defp get_skin(:x, player) do
    assigns = %{}

    case player.cosmetics["x-o-style"] do
      "retro" ->
        ~H"""
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" stroke="none">
          <path><animate attributeName="d" values="M0 0;m5 5v2h2v-2zm12 0v2h2v-2z" begin="0ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m7 7v2h2v-2zm8 0v2h2v-2z" begin="80ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m9 9v2h2v-2zm4 0v2h2v-2z" begin="160ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m11 11h2v2h-2z" begin="240ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m9 13v2h2v-2zm4 0v2h2v-2z" begin="320ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m7 15v2h2v-2zm8 0v2h2v-2z" begin="400ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m5 17v2h2v-2zm12 0v2h2v-2z" begin="480ms" dur="80ms" fill="freeze" /></path>
        </svg>
        """

      "scribble" ->
        ~H"""
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.4">
          <path><animate attributeName="d" values="m6.11 6.75c0.807 1.32 0 0 0 0;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36c1.19 0.671 0 0 0 0;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36c1.19 0.671 2.34 2.16 3.07 2.76;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36c1.19 0.671 2.34 2.16 3.07 2.76c0.609 1.36 0 0 0 0;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36c1.19 0.671 2.34 2.16 3.07 2.76c0.609 1.36 1.31 2.09 2.27 3.41;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36c1.19 0.671 2.34 2.16 3.07 2.76c0.609 1.36 1.31 2.09 2.27 3.41c0.625 0.851 0 0 0 0;m6.11 6.75c0.807 1.32 1.42 1.69 2.84 2.36c1.19 0.671 2.34 2.16 3.07 2.76c0.609 1.36 1.31 2.09 2.27 3.41c0.625 0.851 1.85 1.89 3.51 2.3" dur="0.35s" fill="freeze" keyTimes="0;0.154;0.154;0.338;0.338;0.574;0.574;1" /></path>

          <path><animate attributeName="d" values="m6.21 18c0 0 0 0 0 0;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22c0.825-1.33 0 0 0 0;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22c0.825-1.33 1.71-2.65 2.31-3.61;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22c0.825-1.33 1.71-2.65 2.31-3.61c1.35-0.385 0 0 0 0;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22c0.825-1.33 1.71-2.65 2.31-3.61c1.35-0.385 2.65-2.07 3.53-3.43;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22c0.825-1.33 1.71-2.65 2.31-3.61c1.35-0.385 2.65-2.07 3.53-3.43c0.855-1.45 0 0 0 0;m6.21 18c1.22-1.17 2.06-1.08 3.41-2.22c0.825-1.33 1.71-2.65 2.31-3.61c1.35-0.385 2.65-2.07 3.53-3.43c0.855-1.45 1.5-1.65 2.61-2.53" begin="0.35s" dur="0.35s" fill="freeze" keyTimes="0;0.128;0.168;0.313;0.313;0.622;0.622;1" /></path>
        </svg>
        """

      _ ->
        ~H"""
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4 4" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="0.4">
          <path d="">
            <animate attributeName="d" values="M1 1 l0 0;M1 1 l2 2;M1 1 l2 2 M1 3 l0 0;M1 1 l2 2 M1 3 l2-2" fill="freeze" dur="0.5s" calcMode="spline" keySplines="0 0 0.58 1;0 0 0 0;0 0 0.58 1" keyTimes="0;0.5;0.5;1" repeatCount="1" />
          </path>
        </svg>
        """
    end
  end

  defp get_skin(:o, player) do
    assigns = %{}

    case player.cosmetics["x-o-style"] do
      "retro" ->
        ~H"""
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" stroke="none">
          <path><animate attributeName="d" values="M0 0;m9 5h6v2h-6z" begin="0ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m7 7v2h2v-2zm8 0v2h2v-2z" begin="80ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m5 9v2h2v-2zm12 0v2h2v-2z;m5 9v4h2v-4zm12 0v4h2v-4z;m5 9v6h2v-6zm12 0v6h2v-6z" begin="160ms" dur="240ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m7 15v2h2v-2zm8 0v2h2v-2z" begin="400ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values="M0 0;m9 17h6v2h-6z" begin="480ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
        </svg>
        """

      "scribble" ->
        ~H"""
        <svg version="1.1" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg" fill="none" stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2.4">
          <path><animate attributeName="d" values="m12.7 4.73c2.24 0.831 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51c-1-1.52 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51c-1-1.52-1.21-2.77-1.63-4.71;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51c-1-1.52-1.21-2.77-1.63-4.71c-0.00657-2.08 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51c-1-1.52-1.21-2.77-1.63-4.71c-0.00657-2.08 0.951-3.7 1.66-4.46;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51c-1-1.52-1.21-2.77-1.63-4.71c-0.00657-2.08 0.951-3.7 1.66-4.46c1.14-0.861 0 0 0 0;m12.7 4.73c2.24 0.831 2.93 1.19 3.91 1.86c1.23 0.575 1.94 1.69 1.78 3.28c0.123 0.964 0.19 1.6 0.502 2.54c0.124 1.96-0.963 2.7-1.84 4.56c-1 1.53-3.67 1.75-5.39 1.31c-1.7-0.337-3.42-0.0267-4.82-1.51c-1-1.52-1.21-2.77-1.63-4.71c-0.00657-2.08 0.951-3.7 1.66-4.46c1.14-0.861 2.83-1.21 3.98-1.22" dur="0.75s" fill="freeze" keyTimes="0;0.073;0.073;0.126;0.126;0.175;0.175;0.248;0.248;0.363;0.363;0.492;0.492;0.648;0.648;0.857;0.857;1" /></path>
        </svg>
        """

      _ ->
        ~H"""
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 4 4">
          <circle cx="2" cy="2" r="1.125" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="0.4" stroke-dasharray="7.065" stroke-dashoffset="7.065" transform="rotate(-90 2 2)">
            <animate attributeName="stroke-dashoffset" values="7.065;0" fill="freeze" dur="0.75s" calcMode="spline" keySplines="0 0 0.58 1" repeatCount="1" />
          </circle>
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
    case current do
      :first -> 0
      :second -> 1
      _ -> -1
    end === n
  end

  defp nths_turn?(game_board, n) do
    player_count = 2
    rem(game_board.turn_number, player_count) === n
  end

  defp scroll_chat(socket) do
    push_event(socket, "scroll-end", %{id: "chat"})
  end

  defp clear_message_box(socket) do
    push_event(socket, "clear-input", %{id: "message-box"})
  end
end
