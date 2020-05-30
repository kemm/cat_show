defmodule CatShowWeb.SessionController do
  use CatShowWeb, :controller

  alias CatShow.Accounts
  alias CatShow.Auth.Guardian

  def create(conn, params) do
    case authenticate(params) do
      {:ok, user} ->
        new_conn = Guardian.Plug.sign_in(conn, user)
        token = Guardian.Plug.current_token(new_conn)

        new_conn
        |> put_status(:created)
        |> render("show.json", user: user, token: token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", error: "Email not found or invalid password")
    end
  end

  def delete(conn, _params) do
    conn
    |> Guardian.Plug.sign_out()
    |> render("delete.json")
  end

  def refresh(conn, _params) do
    user = Guardian.Plug.current_resource(conn)
    token = Guardian.Plug.current_token(conn)

    case Guardian.refresh(token, ttl: {30, :days}) do
      {:ok, _, {new_token, _new_claims}} ->
        conn
        |> put_status(:ok)
        |> render("show.json", user: user, token: new_token)

      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render("error.json", error: "Not authenticated")
    end
  end

  defp authenticate(%{"email" => email, "password" => password}) do
    Accounts.authenticate(email, password)
  end

  defp authenticate(_) do
    {:error, :invalid_params}
  end

end
