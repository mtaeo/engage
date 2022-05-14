alias Engage.Repo
alias Engage.Games.Game
alias Engage.Users.User

Repo.insert!(%Game{
  name: "tic-tac-toe",
  display_name: "Tic-Tac-Toe",
  description: "The classic pen-and-paper game for 2 players.",
  xp_multiplier: 1,
  type: :multiplayer,
  image_path: "/images/tic_tac_toe.jpeg",
  shadow_color: "shadow-red-600"
})

Repo.insert!(%Game{
  display_name: "Memory",
  name: "memory",
  description: "Unknown description as of right now.",
  xp_multiplier: 3,
  type: :multiplayer,
  image_path: "/images/memory.jpeg",
  shadow_color: "shadow-cyan-500"
})

Repo.insert!(
  User.registration_changeset(
    %User{},
    %{
      username: "test",
      email: "test@test.com",
      password: "test"
    }
  )
)

Repo.insert!(
  User.registration_changeset(
    %User{},
    %{
      username: "moderator",
      email: "moderator@moderator.com",
      password: "test"
    }
  )
)

Repo.insert!(
  User.registration_changeset(
    %User{},
    %{
      username: "admin",
      email: "admin@admin.com",
      password: "test"
    }
  )
)
