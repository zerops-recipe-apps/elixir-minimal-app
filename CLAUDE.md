<!-- #ZEROPS_EXTRACT_START:claude-md# -->

# app

Minimal Elixir application (Elixir ~> 1.16) that serves HTTP requests via a `Plug.Router` running on the Bandit web server. Depends on `plug` (~> 1.16) and `bandit` (~> 1.5).

## Build & run

- `mix deps.get` — install dependencies
- `mix run --no-halt` — start the application (boots `App.Application`'s supervision tree and keeps it running)
- `mix release` — build an OTP release (configured with `include_executables_for: [:unix]`)

## Architecture

- `lib/app/application.ex` — OTP application entrypoint; starts a one-for-one supervisor with a `Bandit` HTTP server bound to `App.Router`, listening on `PORT` (env var, default `8080`)
- `lib/app/router.ex` — `Plug.Router` defining the HTTP routes: `GET /health` (returns `200 ok`), `GET /` (returns `200 Hello World from Elixir!`), and a catch-all (returns `404 not found`); uses `Plug.Logger` for request logging
<!-- #ZEROPS_EXTRACT_END:claude-md# -->
