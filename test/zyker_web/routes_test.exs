defmodule ZykerWeb.RoutesTest do
  # zyker's routes mounted from a host app's router (ZykerWeb.TestHost).
  use ZykerWeb.ConnCase, async: true

  alias ZykerWeb.TestHost

  # GET `path` through `router`, with what the endpoint sets up before calling it.
  defp dispatch(router, path) do
    build_conn(:get, path)
    |> put_private(:phoenix_endpoint, @endpoint)
    |> init_test_session(%{})
    |> router.call(router.init([]))
  end

  test "serves the host's own routes" do
    assert TestHost.Router |> dispatch("/host") |> response(200) == "host page"
  end

  test "serves zyker's routes through zyker's pipelines" do
    conn = dispatch(TestHost.Router, "/")

    assert html_response(conn, 200) =~ "zyker.dev"
    assert conn.private.phoenix_root_layout == %{"html" => {ZykerWeb.Layouts, :root}}
  end

  test "host routes declared first win over zyker's" do
    assert TestHost.OverridingRouter |> dispatch("/") |> response(200) == "host home"
  end

  test "a host router mounts all of ZykerWeb.Router's routes" do
    zyker_routes = Enum.map(ZykerWeb.Router.__routes__(), &{&1.verb, &1.path})
    host_routes = Enum.map(TestHost.Router.__routes__(), &{&1.verb, &1.path})

    assert zyker_routes -- host_routes == []
  end
end
