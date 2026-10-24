defmodule ZykerWeb.TestHost do
  @moduledoc """
  Stands in for a host app embedding zyker (see `ZykerWeb.Routes` and
  `ZykerWeb.Endpoint`): its routers mount zyker's pipelines and routes.
  """

  defmodule Controller do
    use Phoenix.Controller, formats: [:html]

    def show(conn, _params), do: text(conn, "host page")
    def home(conn, _params), do: text(conn, "host home")
  end

  defmodule Router do
    use ZykerWeb, :router
    require ZykerWeb.Routes

    ZykerWeb.Routes.pipelines()

    scope "/" do
      pipe_through :browser

      get "/host", Controller, :show
    end

    ZykerWeb.Routes.routes()
  end

  # Like Router, but overriding one of zyker's paths.
  defmodule OverridingRouter do
    use ZykerWeb, :router
    require ZykerWeb.Routes

    # Shadowing zyker's "/" is the point of this router; don't warn about it.
    @compile :nowarn_nomatch

    ZykerWeb.Routes.pipelines()

    scope "/" do
      pipe_through :browser

      get "/", Controller, :home
    end

    ZykerWeb.Routes.routes()
  end
end
