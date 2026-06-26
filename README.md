# Zerops x Elixir Hello World

<!-- #ZEROPS_EXTRACT_START:intro# -->

Minimal Elixir HTTP service built on Plug and the Bandit web server, answering a single GET route with a Hello World response.
<!-- #ZEROPS_EXTRACT_END:intro# -->

![elixir cover](https://github.com/zeropsio/recipe-shared-assets/blob/main/covers/svg/cover-elixir.svg)

## Deploy to Zerops

Click the deploy button to deploy directly to Zerops.

[![Deploy on Zerops](https://github.com/zeropsio/recipe-shared-assets/blob/main/deploy-button/light/deploy-button.svg)](https://app.zerops.io/recipes/elixir-minimal?environment=small-production)

## Integration Guide

<!-- #ZEROPS_EXTRACT_START:integration-guide# -->
### 1. Adding `zerops.yaml`

The main configuration file — place at repository root. It tells Zerops how to build, deploy and run your app. This one declares 2 setups (`dev`, `prod`) and ships readiness + health checks.

```yaml
zerops:
  # Two setups, one trade-off: `dev` is a remote-development
  # workspace the porter SSHs into to run `mix run --no-halt` by
  # hand; `prod` builds an OTP release and runs it standalone.
  - setup: dev
    build:
      base: elixir@1.16
      buildCommands:
        # A fresh elixir@1.16 image has neither Hex nor rebar3 —
        # both install before `mix deps.get` can resolve Plug and
        # Bandit from Hex.
        - mix local.hex --force
        - mix local.rebar --force
        - mix deps.get
      # Whole-source deploy — the porter edits and runs code from
      # this tree over SSH, so it needs the full repo.
      deployFiles:
        - .
    run:
      base: elixir@1.16
      ports:
        # `8080` matches the fallback in `System.get_env("PORT",
        # "8080")` (lib/app/application.ex) — feel free to pick a
        # different port, as long as the code's fallback agrees.
        - port: 8080
          httpSupport: true
      # `zsc noop --silent` keeps the container idle — the
      # porter starts `mix run --no-halt` over SSH, and source
      # edits take effect without a redeploy. No readinessCheck
      # or healthCheck either — both would restart mid-edit.
      start: zsc noop --silent
  - setup: prod
    build:
      base: elixir@1.16
      buildCommands:
        # Same Hex/rebar3 bootstrap, then a prod-only dependency
        # fetch and an OTP release build — the release bundles
        # the BEAM runtime with the app, so the runtime needs no
        # Elixir/Mix toolchain at all.
        - mix local.hex --force
        - mix local.rebar --force
        - mix deps.get --only prod
        - MIX_ENV=prod mix compile
        - MIX_ENV=prod mix release app
      # `~` strips the `_build/prod/rel/app/` prefix so only the
      # release ships — `bin/app`, run below via `start`, lands
      # at the deploy root.
      deployFiles:
        - _build/prod/rel/app/~
    deploy:
      readinessCheck:
        # Gates traffic cutover — a new container takes over only
        # once `/health` answers, so a broken release never
        # replaces the previous version.
        httpGet: { port: 8080, path: /health }
    run:
      base: elixir@1.16
      ports:
        - port: 8080
          httpSupport: true
      start: bin/app start
      # Same `/health` path as readiness, polled continuously
      # instead of once — an unhealthy container is pulled from
      # the load balancer and restarted, then reconnected on
      # recovery.
      healthCheck:
        httpGet: { port: 8080, path: /health }
```

### 2. Bind the listener to `0.0.0.0`

Zerops routes HTTP traffic to your container over an internal VXLAN network, not `localhost` — a listener bound to loopback never receives a request and every hit returns `502`. Bandit's `ip` option defaults toward loopback unless set explicitly, so pass it alongside `port` when starting the listener:

```elixir
{Bandit, plug: App.Router, scheme: :http, port: port, ip: {0, 0, 0, 0}}
```

Read the port from `System.get_env("PORT", "8080")` rather than hardcoding it, and keep the fallback value equal to [`run.ports`](zerops.yaml) — Bandit and the platform's L7 balancer need to agree on the same port.

### 3. Add a `/health` route for readiness and health checks

`deploy.readinessCheck` gates the traffic cutover for a freshly deployed container; `run.healthCheck` polls continuously and pulls an unhealthy container from the load balancer until it recovers. Both point at the same path here, so one route serves both:

```elixir
get "/health" do
  send_resp(conn, 200, "ok")
end
```

Keep it free of database or downstream calls — readiness shouldn't gate on a dependency outside this app.

### 4. Name the release in `mix.exs`

The prod build's last step runs `mix release app`. Once a `releases:` key exists at all in `mix.exs`, Mix only resolves names declared there — requesting a name that isn't listed fails the build with `Unknown release :app` before any artifact is produced:

```elixir
def project do
  [
    # ...
    releases: releases()
  ]
end

defp releases do
  [
    app: [include_executables_for: [:unix]]
  ]
end
```

Match the key (`app:`) to whatever name your own build command passes to `mix release`.
<!-- #ZEROPS_EXTRACT_END:integration-guide# -->

<!-- #ZEROPS_EXTRACT_START:knowledge-base# -->

<!-- #ZEROPS_EXTRACT_END:knowledge-base# -->
