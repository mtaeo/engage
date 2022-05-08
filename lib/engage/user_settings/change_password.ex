defmodule Engage.UserSettings.ChangePassword do
  import Ecto.Changeset

  @types %{old_password: :string, new_password: :string, new_password_repeat: :string}

  defstruct [:old_password, :new_password, :new_password_repeat]

  def changeset(%__MODULE__{} = change_password, params \\ %{}) do
    {change_password, @types}
    |> cast(params, Map.keys(@types))
    |> validate_required([:old_password, :new_password, :new_password_repeat])
    |> validate_length(:new_password, min: 4, message: "Needs to be at least 4 characters long")
    |> validate_change(:new_password_repeat, fn :new_password_repeat, new_password_repeat ->
      if new_password_repeat == params["new_password"] do
        []
      else
        [new_password_repeat: "Repeated password is different"]
      end
    end)
  end
end
