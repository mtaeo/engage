defmodule Engage.Games do
  import Ecto.Query, warn: false
  alias Engage.Repo
  alias Engage.Games.{Game}

  def get_all_games do
    Repo.all(Game)
  end

  @doc """
  Gets a list of games by their type.
  Allowed type atoms: :singleplayer, :multiplayer

  ## Examples

      iex> get_all_games_by_type(:singleplayer)
      [%Game{}]

  """
  def get_all_games_by_type(type) when is_atom(type) do
    Repo.all(from g in Game, where: g.type == ^type)
  end

  def get_game_by_name(name) when is_binary(name) do
    Repo.one(from g in Game, where: g.name == ^name)
  end

end
