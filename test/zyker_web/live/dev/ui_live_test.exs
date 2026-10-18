defmodule ZykerWeb.Dev.UILiveTest do
  use ZykerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the showcase and validates the form", %{conn: conn} do
    {:ok, view, html} = live_isolated(conn, ZykerWeb.Dev.UILive)
    assert html =~ "Components"

    # Drive the form through its rendered field names, as a browser would.
    html = view |> form("#showcase-form", showcase: %{email: "nope"}) |> render_change()
    assert html =~ "must contain an @"
  end

  test "shows a flash on demand", %{conn: conn} do
    {:ok, view, _html} = live_isolated(conn, ZykerWeb.Dev.UILive)

    assert view |> element("button", "Error flash") |> render_click() =~ "Example error flash"
  end
end
