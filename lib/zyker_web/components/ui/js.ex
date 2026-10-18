defmodule ZykerWeb.UI.JS do
  @moduledoc """
  Shared `Phoenix.LiveView.JS` commands for showing and hiding elements
  with the library's enter/exit transition.
  """
  alias Phoenix.LiveView.JS

  def show(js \\ %JS{}, selector) do
    JS.show(js,
      to: selector,
      time: 200,
      transition:
        {"transition-all ease-out duration-200",
         "opacity-0 translate-y-2 sm:translate-y-0 sm:scale-95",
         "opacity-100 translate-y-0 sm:scale-100"}
    )
  end

  def hide(js \\ %JS{}, selector) do
    JS.hide(js,
      to: selector,
      time: 150,
      transition:
        {"transition-all ease-in duration-150", "opacity-100 translate-y-0 sm:scale-100",
         "opacity-0 translate-y-2 sm:translate-y-0 sm:scale-95"}
    )
  end
end
