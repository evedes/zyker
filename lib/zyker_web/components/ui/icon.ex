defmodule ZykerWeb.UI.Icon do
  @moduledoc false
  use Phoenix.Component

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Outline style by default; use the `-solid`, `-mini` or `-micro` suffix for
  the other styles. Icons are bundled into app.css by
  `assets/vendor/heroicons.js` and inherit the current text color.

  ## Examples

      <.icon name="hero-x-mark" />
      <.icon name="hero-arrow-path" class="size-3 motion-safe:animate-spin" />
  """
  attr :name, :string, required: true
  attr :class, :any, default: "size-4"
  attr :rest, :global

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span data-slot="icon" class={["shrink-0", @name, @class]} aria-hidden="true" {@rest} />
    """
  end
end
