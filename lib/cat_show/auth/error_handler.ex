defmodule CatShow.Auth.ErrorHandler do
  import Plug.Conn

  def auth_error(conn, {:invalid_token, _reason}, _opts) do
    response(conn, :unauthorized, "Invalid Token")
  end

  def auth_error(conn, {:unauthenticated, _reason}, _opts) do
    response(conn, :unauthorized, "Not Authenticated")
  end

  def auth_error(conn, {:no_resource_found, _reason}, _opts) do
    response(conn, :unauthorized, "No Resource Found")
  end

  def auth_error(conn, {type, _reason}, _opts) do
    response(conn, :forbidden, to_string(type))
  end

  defp response(conn, status, message) do
    body = Poison.encode!(%{error: message})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status, body)
  end
end
