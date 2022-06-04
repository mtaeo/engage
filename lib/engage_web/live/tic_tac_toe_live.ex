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

  defp cell_content(symbol) do
    assigns = %{}

    case symbol do
      :x ->
        ~H(<svg version="1.1" viewBox="0 0 4 4" xmlns="http://www.w3.org/2000/svg"><use href="#x" /></svg>)

      :o ->
        ~H(<svg version="1.1" viewBox="0 0 4 4" xmlns="http://www.w3.org/2000/svg"><use href="#o" /></svg>)

      _ ->
        ""
    end
  end
  
  defp get_skin(player, :x) do
    assigns = %{}
    
    case player.cosmetics["x-o-style"] do
      "retro" ->
        ~H"""
        <symbol id="x" viewBox="0 0 24 24" fill="currentColor" stroke="none">
          <path><animate attributeName="d" values=";m5 5v2h2v-2zm12 0v2h2v-2z" begin="0ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m7 7v2h2v-2zm8 0v2h2v-2z" begin="80ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m9 9v2h2v-2zm4 0v2h2v-2z" begin="160ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m11 11h2v2h-2z" begin="240ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m9 13v2h2v-2zm4 0v2h2v-2z" begin="320ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m7 15v2h2v-2zm8 0v2h2v-2z" begin="400ms" dur="80ms" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m5 17v2h2v-2zm12 0v2h2v-2z" begin="480ms" dur="80ms" fill="freeze" /></path>
        </symbol>
        """
        
      _ ->
        ~H"""
        <symbol id="x" viewBox="0 0 4 4" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="0.4">
          <path d="">
            <animate attributeName="d" values="M1 1 l0 0;M1 1 l2 2;M1 1 l2 2 M1 3 l0 0;M1 1 l2 2 M1 3 l2-2" fill="freeze" dur="0.5s" calcMode="spline" keySplines="0 0 0.58 1;0 0 0 0;0 0 0.58 1" keyTimes="0;0.5;0.5;1" repeatCount="1" />
          </path>
        </symbol>
        """
    end
  end
  
  defp get_skin(player, :o) do
    assigns = %{}
    
    case player.cosmetics["x-o-style"] do
      "retro" ->
        ~H"""
        <symbol id="o" viewBox="0 0 24 24" fill="currentColor" stroke="none">
          <path><animate attributeName="d" values=";m9 5h6v2h-6z" begin="0ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m7 7v2h2v-2zm8 0v2h2v-2z" begin="80ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m5 9v2h2v-2zm12 0v2h2v-2z;m5 9v4h2v-4zm12 0v4h2v-4z;m5 9v6h2v-6zm12 0v6h2v-6z" begin="160ms" dur="240ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m7 15v2h2v-2zm8 0v2h2v-2z" begin="400ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
          <path><animate attributeName="d" values=";m9 17h6v2h-6z" begin="480ms" dur="80ms" calcMode="discrete" fill="freeze" /></path>
        </symbol>
        """
        
      _ ->
        ~H"""
        <symbol id="o" viewBox="0 0 4 4">
          <circle cx="2" cy="2" r="1.125" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="0.4" stroke-dasharray="7.065" stroke-dashoffset="7.065" transform="rotate(-90 2 2)">
            <animate attributeName="stroke-dashoffset" values="7.065;0" fill="freeze" dur="0.75s" calcMode="spline" keySplines="0 0 0.58 1" repeatCount="1" />
          </circle>
        </symbol>
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
