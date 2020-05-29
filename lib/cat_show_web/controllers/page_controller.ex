defmodule CatShowWeb.PageController do
  use CatShowWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
