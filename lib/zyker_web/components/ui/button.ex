defmodule ZykerWeb.UI.Button do
  @moduledoc false
  use Phoenix.Component

  @base "inline-flex shrink-0 items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all outline-none cursor-pointer disabled:pointer-events-none disabled:opacity-50 focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 phx-click-loading:opacity-70 phx-submit-loading:opacity-70"

  @variants %{
    "default" => "bg-primary text-primary-foreground shadow-xs hover:bg-primary/90",
    "destructive" =>
      "bg-destructive text-white shadow-xs hover:bg-destructive/90 focus-visible:ring-destructive/20 dark:bg-destructive/60 dark:focus-visible:ring-destructive/40",
    "outline" =>
      "border bg-background shadow-xs hover:bg-accent hover:text-accent-foreground dark:border-input dark:bg-input/30 dark:hover:bg-input/50",
    "secondary" => "bg-secondary text-secondary-foreground shadow-xs hover:bg-secondary/80",
    "ghost" => "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50",
    "link" => "text-primary underline-offset-4 hover:underline"
  }

  @sizes %{
    "default" => "h-9 px-4 py-2",
    "sm" => "h-8 gap-1.5 px-3",
    "lg" => "h-10 px-6",
    "icon" => "size-9"
  }

  @doc """
  Renders a button, or a link styled as one when `href`, `navigate` or
  `patch` is given.

  ## Examples

      <.button>Save</.button>
      <.button variant="outline" size="sm" phx-click="cancel">Cancel</.button>
      <.button variant="ghost" size="icon" aria-label="Close"><.icon name="hero-x-mark" /></.button>
      <.button navigate={~p"/"}>Home</.button>
  """
  attr :variant, :string, default: "default", values: Map.keys(@variants)
  attr :size, :string, default: "default", values: Map.keys(@sizes)
  attr :class, :any, default: nil

  attr :rest, :global,
    include: ~w(href navigate patch method download name value disabled form type)

  slot :inner_block, required: true

  def button(assigns) do
    assigns =
      assign(assigns, :classes, [
        @base,
        @variants[assigns.variant],
        @sizes[assigns.size],
        assigns.class
      ])

    if assigns.rest[:href] || assigns.rest[:navigate] || assigns.rest[:patch] do
      ~H"""
      <.link data-slot="button" data-variant={@variant} class={@classes} {@rest}>
        {render_slot(@inner_block)}
      </.link>
      """
    else
      ~H"""
      <button data-slot="button" data-variant={@variant} class={@classes} {@rest}>
        {render_slot(@inner_block)}
      </button>
      """
    end
  end
end
