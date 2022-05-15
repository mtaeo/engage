alias Engage.Repo
alias Engage.Games.{Game, XpToLevel}
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

Repo.insert!(%XpToLevel{id: 1, level: 1, min_xp: 0})
Repo.insert!(%XpToLevel{id: 2, level: 2, min_xp: 10})
Repo.insert!(%XpToLevel{id: 3, level: 3, min_xp: 25})
Repo.insert!(%XpToLevel{id: 4, level: 4, min_xp: 50})
Repo.insert!(%XpToLevel{id: 5, level: 5, min_xp: 75})
Repo.insert!(%XpToLevel{id: 6, level: 6, min_xp: 100})
Repo.insert!(%XpToLevel{id: 7, level: 7, min_xp: 200})
Repo.insert!(%XpToLevel{id: 8, level: 8, min_xp: 300})
Repo.insert!(%XpToLevel{id: 9, level: 9, min_xp: 500})
Repo.insert!(%XpToLevel{id: 10, level: 10, min_xp: 750})
Repo.insert!(%XpToLevel{id: 11, level: 11, min_xp: 1_000})
Repo.insert!(%XpToLevel{id: 12, level: 12, min_xp: 1_500})
Repo.insert!(%XpToLevel{id: 13, level: 13, min_xp: 2_500})
Repo.insert!(%XpToLevel{id: 14, level: 14, min_xp: 5_000})
Repo.insert!(%XpToLevel{id: 15, level: 15, min_xp: 10_000})

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
