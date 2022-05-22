defmodule Engage.Helpers.Gravatar do
  @base_path "https://www.gravatar.com/avatar/"
  def get_image_src_by_email(email, style \\ :retro, size \\ 200)
      when is_binary(email) and is_atom(style) and is_number(size) do
    email =
      email
      |> String.trim()
      |> String.downcase()

    @base_path <>
      Base.encode16(:crypto.hash(:md5, email), case: :lower) <> "?d=" <> Atom.to_string(style) <> "&s=#{size}"
  end
end
