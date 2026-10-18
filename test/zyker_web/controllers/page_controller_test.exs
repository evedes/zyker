defmodule ZykerWeb.PageControllerTest do
  use ZykerWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "zyker.dev"
  end
end
