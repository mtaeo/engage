defmodule Engage.UserSettings.Profile do
  import Ecto.Changeset

  @types %{email: :string, username: :string, bio: :string, theme: :string}

  defstruct [:email, :username, :bio, :theme]

  def changeset(%__MODULE__{} = profile, params \\ %{}) do
    {profile, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required([:email, :username, :theme], message: "Can't be empty")
    |> validate_format(:email, ~R/[a-z0-9.]+@[a-z0-9.]+\.[a-z]+/, message: "Invalid e-mail format")
    |> validate_length(:bio, count: :bytes, max: 256, message: "Max. 256 characters")
  end
end
