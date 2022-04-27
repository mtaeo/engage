defmodule EngageWeb.TicTacToeLive do
  use EngageWeb, :live_view
  alias Engage.TicTacToe.GameBoard
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GenServer

  def mount(_params, session, socket) do
    socket =
      if connected?(socket) do
        setup(socket, session)
      else
        assign(socket, player: nil, game_board: %GameBoard{})
      end

    {:ok, socket}
  end

  def handle_event("make-move", %{"coordinate-x" => x, "coordinate-y" => y}, socket) do
    coordinate = get_coordinate(x, y)
    GenServer.make_move(:test, {socket.assigns.player, coordinate})
    {:noreply, socket}
  end

  def handle_info(%GameBoard{} = board, socket) do
    {:noreply, assign(socket, game_board: board)}
  end

  defp setup(socket, session) do
    GenServer.start_link()
    Phoenix.PubSub.subscribe(Engage.PubSub, "test")

    player_name = session["current_user"].email
    GenServer.add_player(:test, player_name)
    player = GenServer.get_player_by_name(:test, player_name)

    game_board = GenServer.view(:test)

    assign(socket, player: player, game_board: game_board)
  end

  defp get_coordinate(x, y) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)
    %Coordinate{x: x, y: y}
  end
end
