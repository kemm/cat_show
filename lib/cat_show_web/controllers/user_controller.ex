defmodule CatShowWeb.UserController do
  use CatShowWeb, :controller

  alias CatShow.Accounts
  alias CatShow.Accounts.User
  alias CatShow.Auth.Guardian

  action_fallback(CatShowWeb.FallbackController)

  def create(conn, params) do
    with {:ok, %User{} = user} <- Accounts.create_user(params) do
      new_conn = Guardian.Plug.sign_in(conn, user)
      token = Guardian.Plug.current_token(new_conn)

      new_conn
      |> put_status(:created)
      |> render(CatShowWeb.SessionView, "show.json", user: user, token: token)
    end
  end
end
