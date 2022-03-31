# Engage

Web platform containing a variety of multiplayer and singleplayer games to play with friends while earning virtual coins and unlocking rewards.

## Usage

Clone the repository

```bash
$ git clone https://github.com/mtaeo/engage.git engage
$ cd engage
```

Install Elixir and Hex package manager

```bash
$ elixir -v #1.13.3 / OTP24
$ mix local.hex
```

To start Engage web application:

1. Install mix dependencies with:
    ```bash
    $ mix deps.get
    ```

2. Make sure you have PostgreSQL installed and then configure the database accordingly in config/dev.exs and config/test.exs.

4. Create and migrate the database with:
    ```bash
    $ mix ecto.create
    $ mix ecto.migrate
    ```
    
4. Seed the database with:
    ```bash
    $ mix run priv/repo/seeds.exs
    ```
    
5. Create corresponding .env.dev file as provided at the bottom of the readme

6. Start Phoenix server after setting environment variables 
    ```bash
    $ source .env.dev && mix phx.server
    ```

Now you can visit `localhost:4000` from your browser.

## Environment Variables

Create a .env.dev file in your root directory with the following environment variables

```bash
#!/bin/sh

export SECRET_KEY_BASE=
export SECRET_KEY_BASE_TEST=
export DB_USER=
export DB_PASSWORD=
export DB_NAME=
export DB_HOST=
export GITHUB_CLIENT_ID=
export GITHUB_CLIENT_SECRET=
export GOOGLE_CLIENT_ID=
export GOOGLE_CLIENT_SECRET=
```