defmodule ZykerWeb.Router do
  use ZykerWeb, :router
  require ZykerWeb.Routes

  # Pipelines and routes live in ZykerWeb.Routes so host apps can mount them too.
  ZykerWeb.Routes.pipelines()
  ZykerWeb.Routes.routes()
end
