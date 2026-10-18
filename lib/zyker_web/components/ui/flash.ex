defmodule ZykerWeb.UI.Flash do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: ZykerWeb.Gettext

  import ZykerWeb.UI.Icon
  import ZykerWeb.UI.JS

  alias Phoenix.LiveView.JS

  @doc """
  Renders a flash notice as a toast-style alert. Click to dismiss.

  Render flashes through `ZykerWeb.Layouts.flash_group/1`, which positions
  them; use this directly only for custom notices like the reconnect ones.

  ## Examples

      <.flash kind={:info} flash={@flash} />
      <.flash id="saved" kind={:info} title="Saved">Your changes are live.</.flash>
  """
  attr :id, :string, doc: "the optional id of flash container"
  attr :flash, :map, default: %{}, doc: "the map of flash messages to display"
  attr :title, :string, default: nil
  attr :kind, :atom, values: [:info, :error], doc: "used for styling and flash lookup"
  attr :rest, :global, doc: "the arbitrary HTML attributes to add to the flash container"

  slot :inner_block, doc: "the optional inner block that renders the flash message"

  def flash(assigns) do
    assigns = assign_new(assigns, :id, fn -> "flash-#{assigns.kind}" end)

    ~H"""
    <div
      :if={msg = render_slot(@inner_block) || Phoenix.Flash.get(@flash, @kind)}
      id={@id}
      phx-click={JS.push("lv:clear-flash", value: %{key: @kind}) |> hide("##{@id}")}
      role="alert"
      data-slot="flash"
      data-kind={@kind}
      class="pointer-events-auto w-full cursor-pointer"
      {@rest}
    >
      <div class={[
        "flex items-start gap-3 rounded-lg border bg-popover p-4 text-sm text-popover-foreground shadow-lg",
        @kind == :error && "text-destructive"
      ]}>
        <.icon :if={@kind == :info} name="hero-information-circle-mini" class="mt-0.5 size-4" />
        <.icon :if={@kind == :error} name="hero-exclamation-circle-mini" class="mt-0.5 size-4" />
        <div class="grid flex-1 gap-1">
          <p :if={@title} data-slot="flash-title" class="font-medium">{@title}</p>
          <p
            data-slot="flash-description"
            class={if @kind == :error, do: "text-destructive/90", else: "text-muted-foreground"}
          >
            {msg}
          </p>
        </div>
        <button
          type="button"
          class="cursor-pointer rounded-sm opacity-60 transition-opacity hover:opacity-100"
          aria-label={gettext("close")}
        >
          <.icon name="hero-x-mark-mini" class="size-4" />
        </button>
      </div>
    </div>
    """
  end
end
