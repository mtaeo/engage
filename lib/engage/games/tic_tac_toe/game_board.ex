defmodule Engage.Games.TicTacToe.GameBoard do
  alias Engage.Games.Generic.Coordinate

  defstruct state: %{
              %Coordinate{x: 0, y: 0} => nil,
              %Coordinate{x: 0, y: 1} => nil,
              %Coordinate{x: 0, y: 2} => nil,
              %Coordinate{x: 1, y: 0} => nil,
              %Coordinate{x: 1, y: 1} => nil,
              %Coordinate{x: 1, y: 2} => nil,
              %Coordinate{x: 2, y: 0} => nil,
              %Coordinate{x: 2, y: 1} => nil,
              %Coordinate{x: 2, y: 2} => nil
            },
            turn_number: 0,
            outcome: nil
end
