# elixir-minimal-app

Minimal Elixir application (Plug + Bandit) serving HTTP on Zerops — baseline Elixir web recipe with dev workspace and OTP release prod deploy.

## Zerops service facts

- HTTP port: `8080`
- Siblings: —
- Runtime base: `elixir@1.16`

## Zerops dev

`setup: dev` idles on `zsc noop --silent`; the agent starts the dev server.

- Dev command: `mix run --no-halt`
- In-container rebuild without deploy: `MIX_ENV=prod mix release app`

**All platform operations (start/stop/status/logs of the dev server, deploy, env / scaling / storage / domains) go through the Zerops development workflow via `zcp` MCP tools. Don't shell out to `zcli`.**

## Notes

- `lib/app/application.ex` listens on `PORT` (env var, default `8080`) — keep in sync with `zerops.yaml` ports.
- Prod deploy ships only `_build/prod/rel/app/` and starts via `bin/app start`.
- Routes: `GET /health` → `200 ok`, `GET /` → `200 Hello World from Elixir!`.
