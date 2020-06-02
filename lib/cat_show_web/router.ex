defmodule CatShowWeb.Router do
  use CatShowWeb, :router

  pipeline :browser do
    plug :accepts, ["htm", "html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug(CatShow.Auth.Pipeline)
  end

  scope "/", CatShowWeb do
    pipe_through :browser

    get("/*path", PageController, :index)
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
