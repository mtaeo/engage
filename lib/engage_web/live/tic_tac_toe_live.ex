defmodule EngageWeb.TicTacToeLive do
  use Phoenix.LiveView, layout: {EngageWeb.LayoutView, "game.html"}
  alias EngageWeb.Router.Helpers, as: Routes
  alias Engage.Games.Generic.Coordinate
  alias Engage.Games.TicTacToe
  alias Engage.Games.TicTacToe.GameBoard
  alias Engage.Games.Chat
  alias Engage.Games.Chat.Message
  import EngageWeb.LiveHelpers

  def mount(_params, session, socket) do
    socket =
      live_auth_check(socket, session, fn socket, _user ->
        setup(socket, session)
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

    {:noreply,
     assign(socket,
       nth: nth,
       game_code: game_code,
       players: players,
       game_board: game_board,
       messages: messages,
       game_genserver_name: game_genserver_name,
       chat_genserver_name: chat_genserver_name
     )}
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
      text: text,
      sent_at: NaiveDateTime.local_now()
    }

    Chat.GenServer.send_message(
      socket.assigns.chat_genserver_name,
      message
    )

    {:noreply, socket}
  end

  def handle_info(%GameBoard{} = game_board, socket) do
    {:noreply, assign(socket, game_board: game_board)}
  end

  def handle_info(players, socket) when is_map(players) do
    {:noreply, assign(socket, players: players)}
  end

  def handle_info(messages, socket) when is_list(messages) do
    {:noreply, assign(socket, messages: messages)}
  end

  defp setup(socket, session) do
    assign(socket,
      player_id: session["current_user"].id,
      player_name: session["current_user"].username,
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
        ~H"""
        <svg version="1.1" viewBox="0 0 4 4" xmlns="http://www.w3.org/2000/svg">
        	<path fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="0.4" d="">
        		<animate attributeName="d" values="M1 1 l0 0;M1 1 l2 2;M1 1 l2 2 M1 3 l0 0;M1 1 l2 2 M1 3 l2-2" fill="freeze" dur="0.5s" calcMode="spline" keySplines="0 0 0.58 1;0 0 0 0;0 0 0.58 1" keyTimes="0;0.5;0.5;1" repeatCount="1" />
        	</path>
        </svg>
        """

      :o ->
        ~H"""
        <svg version="1.1" viewBox="0 0 4 4" xmlns="http://www.w3.org/2000/svg">
        	<circle cx="2" cy="2" r="1.125" fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="0.4" stroke-dasharray="7.065" stroke-dashoffset="7.065" transform="rotate(-90 2 2)">
        		<animate attributeName="stroke-dashoffset" values="7.065;0" fill="freeze" dur="0.75s" calcMode="spline" keySplines="0 0 0.58 1" repeatCount="1" />
        	</circle>
        </svg>
        """

      _ ->
        ""
    end
  end
end
