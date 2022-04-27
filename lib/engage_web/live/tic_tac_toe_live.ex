defmodule EngageWeb.TicTacToeLive do
  use EngageWeb, :live_view
  alias Engage.TicTacToe.GameBoard
  alias Engage.TicTacToe.Coordinate
  alias Engage.TicTacToe.GenServer

  def mount(_params, session, socket) do
    {:ok, assign(socket, player_name: session["current_user"].email, game_board: %GameBoard{})}
  end

  def handle_params(%{"id" => game_id}, _uri, socket) do
    genserver_name = String.to_atom(game_id)
    GenServer.start_link(genserver_name)
    Phoenix.PubSub.subscribe(Engage.PubSub, game_id)

    GenServer.add_player(genserver_name, socket.assigns.player_name)
    player = GenServer.get_player_by_name(genserver_name, socket.assigns.player_name)
    game_board = GenServer.view(genserver_name)

    {:noreply,
     assign(socket, player: player, game_board: game_board, genserver_name: genserver_name)}
  end

  def handle_event("make-move", %{"coordinate-x" => x, "coordinate-y" => y}, socket) do
    coordinate = get_coordinate(x, y)
    GenServer.make_move(socket.assigns.genserver_name, {socket.assigns.player, coordinate})
    {:noreply, socket}
  end

  def handle_info(%GameBoard{} = board, socket) do
    {:noreply, assign(socket, game_board: board)}
  end

  defp get_coordinate(x, y) do
    {x, ""} = Integer.parse(x)
    {y, ""} = Integer.parse(y)
    %Coordinate{x: x, y: y}
  end
end
