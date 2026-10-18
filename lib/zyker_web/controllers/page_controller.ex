defmodule ZykerWeb.PageController do
  use ZykerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
