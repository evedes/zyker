defmodule ZykerWeb.UI.Table do
  @moduledoc false
  use Phoenix.Component
  use Gettext, backend: ZykerWeb.Gettext

  @doc """
  Renders a table. Accepts a list or a LiveView stream as `rows`.

  ## Examples

      <.table id="users" rows={@users}>
        <:col :let={user} label="id">{user.id}</:col>
        <:col :let={user} label="username">{user.username}</:col>
      </.table>
  """
  attr :id, :string, required: true
  attr :rows, :list, required: true
  attr :row_id, :any, default: nil, doc: "the function for generating the row id"
  attr :row_click, :any, default: nil, doc: "the function for handling phx-click on each row"

  attr :row_item, :any,
    default: &Function.identity/1,
    doc: "the function for mapping each row before calling the :col and :action slots"

  slot :col, required: true do
    attr :label, :string
  end

  slot :action, doc: "the slot for showing user actions in the last table column"

  def table(assigns) do
    assigns =
      with %{rows: %Phoenix.LiveView.LiveStream{}} <- assigns do
        assign(assigns, row_id: assigns.row_id || fn {id, _item} -> id end)
      end

    ~H"""
    <div data-slot="table-container" class="relative w-full overflow-x-auto">
      <table data-slot="table" class="w-full caption-bottom text-sm">
        <thead data-slot="table-header" class="[&_tr]:border-b">
          <tr data-slot="table-row">
            <th
              :for={col <- @col}
              data-slot="table-head"
              class="h-10 px-2 text-left align-middle font-medium whitespace-nowrap text-muted-foreground"
            >
              {col[:label]}
            </th>
            <th :if={@action != []} data-slot="table-head" class="h-10 px-2">
              <span class="sr-only">{gettext("Actions")}</span>
            </th>
          </tr>
        </thead>
        <tbody
          id={@id}
          data-slot="table-body"
          phx-update={is_struct(@rows, Phoenix.LiveView.LiveStream) && "stream"}
          class="[&_tr:last-child]:border-0"
        >
          <tr
            :for={row <- @rows}
            id={@row_id && @row_id.(row)}
            data-slot="table-row"
            class="border-b transition-colors hover:bg-muted/50"
          >
            <td
              :for={col <- @col}
              data-slot="table-cell"
              phx-click={@row_click && @row_click.(row)}
              class={["p-2 align-middle whitespace-nowrap", @row_click && "cursor-pointer"]}
            >
              {render_slot(col, @row_item.(row))}
            </td>
            <td :if={@action != []} data-slot="table-cell" class="w-0 p-2 align-middle">
              <div class="flex items-center justify-end gap-1">
                <%= for action <- @action do %>
                  {render_slot(action, @row_item.(row))}
                <% end %>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a description list.

  ## Examples

      <.list>
        <:item title="Title">{@post.title}</:item>
        <:item title="Views">{@post.views}</:item>
      </.list>
  """
  slot :item, required: true do
    attr :title, :string, required: true
  end

  def list(assigns) do
    ~H"""
    <dl data-slot="list" class="divide-y text-sm">
      <div :for={item <- @item} data-slot="list-item" class="grid gap-1 py-3 sm:grid-cols-3 sm:gap-4">
        <dt class="font-medium">{item.title}</dt>
        <dd class="text-muted-foreground sm:col-span-2">{render_slot(item)}</dd>
      </div>
    </dl>
    """
  end
end
