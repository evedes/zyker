defmodule ZykerWeb.Routes do
  @moduledoc """
  Zyker's pipelines and routes, as macros so a host router can mount them.

  `ZykerWeb.Router` is the standalone host. Another app (e.g. zyker-cloud) points
  the endpoint at its own router (see `ZykerWeb.Endpoint`) and calls these there:

      defmodule MyAppWeb.Router do
        use ZykerWeb, :router
        require ZykerWeb.Routes

        ZykerWeb.Routes.pipelines()

        scope "/billing", MyAppWeb do
          pipe_through :browser
          # ...
        end

        ZykerWeb.Routes.routes()
      end
  """

  defmacro pipelines do
    quote do
      pipeline :browser do
        plug :accepts, ["html"]
        plug :fetch_session
        plug :fetch_live_flash
        plug :put_root_layout, html: {ZykerWeb.Layouts, :root}
        plug :protect_from_forgery
        plug :put_secure_browser_headers
      end

      pipeline :api do
        plug :accepts, ["json"]
      end
    end
  end

  defmacro routes do
    quote do
      scope "/", ZykerWeb do
        pipe_through :browser

        get "/", PageController, :home
      end

      # Other scopes may use custom stacks.
      # scope "/api", ZykerWeb do
      #   pipe_through :api
      # end

      # Enable LiveDashboard and Swoosh mailbox preview in development
      if Application.compile_env(:zyker, :dev_routes) do
        # If you want to use the LiveDashboard in production, you should put
        # it behind authentication and allow only admins to access it.
        # If your application does not have an admins-only section yet,
        # you can use Plug.BasicAuth to set up some basic authentication
        # as long as you are also using SSL (which you should anyway).
        import Phoenix.LiveDashboard.Router

        scope "/dev" do
          pipe_through :browser

          live "/ui", ZykerWeb.Dev.UILive
          live_dashboard "/dashboard", metrics: ZykerWeb.Telemetry
          forward "/mailbox", Plug.Swoosh.MailboxPreview
        end
      end
    end
  end
end
