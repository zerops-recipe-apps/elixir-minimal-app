defmodule App.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/health" do
    send_resp(conn, 200, "ok")
  end

  get "/" do
    send_resp(conn, 200, "Hello World from Elixir!")
  end

  match _ do
    send_resp(conn, 404, "not found")
  end
end
