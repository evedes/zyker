defmodule ZykerWeb.UI.Header do
  @moduledoc false
  use Phoenix.Component

  @doc """
  Renders a page header with an optional subtitle and actions.

  ## Examples

      <.header>
        Listing posts
        <:subtitle>Everything published so far.</:subtitle>
        <:actions><.button navigate={~p"/posts/new"}>New post</.button></:actions>
      </.header>
  """
  attr :class, :any, default: nil
  slot :inner_block, required: true
  slot :subtitle
  slot :actions

  def header(assigns) do
    ~H"""
    <header data-slot="header" class={["flex items-center justify-between gap-6 pb-6", @class]}>
      <div class="grid gap-1">
        <h1 data-slot="header-title" class="text-2xl font-semibold tracking-tight">
          {render_slot(@inner_block)}
        </h1>
        <p :if={@subtitle != []} data-slot="header-subtitle" class="text-sm text-muted-foreground">
          {render_slot(@subtitle)}
        </p>
      </div>
      <div :if={@actions != []} data-slot="header-actions" class="flex flex-none items-center gap-2">
        {render_slot(@actions)}
      </div>
    </header>
    """
  end
end
