alias Engage.Repo
alias Engage.Cosmetics.{Cosmetic, UserCosmetic}
alias Engage.Games.{Game, XpToLevel}
alias Engage.Users.User
alias Engage.Challenges.Quiz.{Quiz, Question, Answer}

Repo.insert!(%Game{
  name: "tic-tac-toe",
  display_name: "Tic-Tac-Toe",
  description: "The classic pen-and-paper game for 2 players.
                The player who succeeds in placing three of their marks in a horizontal,
                vertical, or diagonal row is the winner.",
  xp_multiplier: 1,
  type: :multiplayer,
  image_path: "/images/game-previews/tic_tac_toe.jpg"
})

Repo.insert!(%Game{
  display_name: "Memory",
  name: "memory",
  description: "Each person turns over two cards at a time,
                with the goal of turning over a matching pair, by using their memory.",
  xp_multiplier: 5,
  type: :multiplayer,
  image_path: "/images/game-previews/memory.jpg"
})

Repo.insert!(%Game{
  display_name: "Rock Paper Scissors",
  name: "rock-paper-scissors",
  description: "A hand game originating from China, played between two people,
                in which each player simultaneously forms one of three shapes with an outstretched hand.",
  xp_multiplier: 1,
  type: :multiplayer,
  image_path: "/images/game-previews/rock-paper-scissors.jpg"
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
    %User{
      coins: 1000
    },
    %{
      username: "test",
      email: "test@test.com",
      password: "test",
      confirmed_at: NaiveDateTime.local_now()
    }
  )
)

Repo.insert!(
  User.registration_changeset(
    %User{
      coins: 5000
    },
    %{
      username: "moderator",
      email: "moderator@moderator.com",
      password: "test",
      confirmed_at: NaiveDateTime.local_now()
    }
  )
)

Repo.insert!(
  User.registration_changeset(
    %User{
      coins: 9999
    },
    %{
      username: "admin",
      email: "admin@admin.com",
      password: "test",
      confirmed_at: NaiveDateTime.local_now()
    }
  )
)

Repo.insert!(
  Cosmetic.changeset(
    %Cosmetic{},
    %{
      name: "retro",
      display_name: "Retro",
      game_id: 1,
      category: :game_item,
      exclusion_group: "x-o-style",
      data: nil,
      price: 250
    }
  )
)

Repo.insert!(
  Cosmetic.changeset(
    %Cosmetic{},
    %{
      name: "scribble",
      display_name: "Scribble",
      game_id: 1,
      category: :game_item,
      exclusion_group: "x-o-style",
      data: nil,
      price: 250
    }
  )
)

Repo.insert!(
  Cosmetic.changeset(
    %Cosmetic{},
    %{
      name: "engage",
      display_name: "Engage cards",
      game_id: 2,
      category: :game_item,
      exclusion_group: "card-skin",
      data: nil,
      price: 500
    }
  )
)

Repo.insert!(
  Cosmetic.changeset(
    %Cosmetic{},
    %{
      name: "stars",
      display_name: "Stars cards",
      game_id: 2,
      category: :game_item,
      exclusion_group: "card-skin",
      data: nil,
      price: 500
    }
  )
)

Repo.insert!(
  Cosmetic.changeset(
    %Cosmetic{},
    %{
      name: "diamonds",
      display_name: "Diamonds cards",
      game_id: 2,
      category: :game_item,
      exclusion_group: "card-skin",
      data: nil,
      price: 500
    }
  )
)

Repo.insert!(%UserCosmetic{
  user_id: 1,
  cosmetic_id: 1
})

Repo.insert!(%Quiz{
  display_name: "Quick Maths",
  category: "Sports",
  seconds_per_question: 45,
  utc_start_date:
    DateTime.utc_now()
    |> DateTime.truncate(:second)
})

Repo.insert!(%Question{
  quiz_id: 1,
  text: "What is 2+2?"
})

Repo.insert!(%Question{
  quiz_id: 1,
  text: "What is 10+10?"
})

Repo.insert!(%Question{
  quiz_id: 1,
  text: "What is 50+50?"
})

Repo.insert(%Answer{
  question_id: 1,
  text: "4",
  is_correct: true
})

Repo.insert(%Answer{
  question_id: 1,
  text: "6"
})

Repo.insert(%Answer{
  question_id: 1,
  text: "8"
})

Repo.insert(%Answer{
  question_id: 1,
  text: "10"
})

Repo.insert(%Answer{
  question_id: 2,
  text: "15"
})

Repo.insert(%Answer{
  question_id: 2,
  text: "20",
  is_correct: true
})

Repo.insert(%Answer{
  question_id: 2,
  text: "30"
})

Repo.insert(%Answer{
  question_id: 2,
  text: "40"
})

Repo.insert(%Answer{
  question_id: 3,
  text: "200"
})

Repo.insert(%Answer{
  question_id: 3,
  text: "150"
})

Repo.insert(%Answer{
  question_id: 3,
  text: "25"
})

Repo.insert(%Answer{
  question_id: 3,
  text: "100",
  is_correct: true
})
