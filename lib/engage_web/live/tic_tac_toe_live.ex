defmodule EngageWeb.TicTacToeLive do
  use EngageWeb, :live_view
  alias Engage.TicTacToe.GameBoard
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GenServer

  def mount(_params, session, socket) do
    {:ok, setup(socket, session)}
  end

  def handle_params(%{"id" => game_id}, _uri, socket) do
    genserver_name = String.to_atom(game_id)
    GenServer.start(genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_id)

    players = GenServer.add_player(genserver_name, socket.assigns.player_name)
    player = GenServer.get_player_by_name(genserver_name, socket.assigns.player_name)
    game_board = GenServer.view(genserver_name)

    {:noreply,
     assign(socket,
       player: player,
       players: players,
       game_board: game_board,
       genserver_name: genserver_name
     )}
  end

  def handle_event("make-move", %{"coordinate-x" => x, "coordinate-y" => y}, socket) do
    coordinate = get_coordinate(x, y)
    GenServer.make_move(socket.assigns.genserver_name, {socket.assigns.player, coordinate})
    {:noreply, socket}
  end

  def handle_info(%GameBoard{} = game_board, socket) do
    {:noreply, assign(socket, game_board: game_board)}
  end

  def handle_info(players, socket) when is_map(players) do
    {:noreply, assign(socket, players: players)}
  end

  defp setup(socket, session) do
    assign(socket,
      player_name: session["current_user"].username,
      game_board: %GameBoard{},
      players: %{first: nil, second: nil}
    )
  end

  defp get_coordinate(x, y) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)
    %Coordinate{x: x, y: y}
  end
end
