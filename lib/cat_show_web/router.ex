defmodule CatShowWeb.Router do
  use CatShowWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug(CatShow.Auth.Pipeline)
  end

  scope "/api", CatShowWeb do
    pipe_through :api

    post("/sessions", SessionController, :create)
    post("/users", UserController, :create)
  end

  scope "/api", CatShowWeb do
    pipe_through [:api, :api_auth]

    delete("/sessions", SessionController, :delete)
    post("/sessions/refresh", SessionController, :refresh)
  end
end
