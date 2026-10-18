defmodule ZykerWeb.Dev.UILive do
  @moduledoc """
  Dev-only showcase of the component library, served at /dev/ui.
  Add every new component here with its variants.
  """
  use ZykerWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "UI")
     |> assign(
       :form,
       to_form(%{"email" => "", "role" => "", "bio" => "", "terms" => false}, as: :showcase)
     )
     |> assign(:rows, [
       %{id: 1, name: "seaweedfs", status: "running"},
       %{id: 2, name: "postgres", status: "running"}
     ])}
  end

  @impl true
  def handle_event("validate", %{"showcase" => params}, socket) do
    errors =
      if String.contains?(params["email"], "@"),
        do: [],
        else: [email: {"must contain an @", []}]

    form = to_form(params, as: :showcase, errors: errors, action: :validate)
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("flash", %{"kind" => kind}, socket) do
    kind = String.to_existing_atom(kind)
    {:noreply, put_flash(socket, kind, "Example #{kind} flash. Click to dismiss.")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Components
        <:subtitle>zyker's component library, in every variant.</:subtitle>
        <:actions>
          <.button variant="outline" size="sm" phx-click={JS.toggle_class("dark", to: "html")}>
            <.icon name="hero-moon-mini" /> Toggle dark
          </.button>
        </:actions>
      </.header>

      <div class="grid gap-12">
        <section class="grid gap-4">
          <h2 class="text-lg font-semibold">Button</h2>
          <div class="flex flex-wrap items-center gap-2">
            <.button>Default</.button>
            <.button variant="secondary">Secondary</.button>
            <.button variant="outline">Outline</.button>
            <.button variant="ghost">Ghost</.button>
            <.button variant="destructive">Destructive</.button>
            <.button variant="link">Link</.button>
            <.button disabled>Disabled</.button>
          </div>
          <div class="flex flex-wrap items-center gap-2">
            <.button size="sm">Small</.button>
            <.button>Default</.button>
            <.button size="lg">Large</.button>
            <.button size="icon" variant="outline" aria-label="Add">
              <.icon name="hero-plus" />
            </.button>
            <.button navigate={~p"/"} variant="outline">
              <.icon name="hero-arrow-left-mini" /> As a link
            </.button>
          </div>
        </section>

        <section class="grid gap-4">
          <h2 class="text-lg font-semibold">Form</h2>
          <.form for={@form} id="showcase-form" phx-change="validate" class="grid max-w-sm gap-6">
            <.input
              field={@form[:email]}
              type="email"
              label="Email"
              placeholder="you@zyker.dev"
              description="Type something without an @ to see the error state."
            />
            <.input
              field={@form[:role]}
              type="select"
              label="Role"
              prompt="Choose a role"
              options={[Admin: "admin", User: "user"]}
            />
            <.input field={@form[:bio]} type="textarea" label="Bio" placeholder="A few words" />
            <.input field={@form[:terms]} type="checkbox" label="I accept the terms" />
            <.input name="disabled" value="" label="Disabled" disabled />
          </.form>
        </section>

        <section class="grid gap-4">
          <h2 class="text-lg font-semibold">Flash</h2>
          <div class="flex gap-2">
            <.button variant="outline" phx-click="flash" phx-value-kind="info">Info flash</.button>
            <.button variant="outline" phx-click="flash" phx-value-kind="error">Error flash</.button>
          </div>
        </section>

        <section class="grid gap-4">
          <h2 class="text-lg font-semibold">Table</h2>
          <.table id="services" rows={@rows}>
            <:col :let={row} label="Service">{row.name}</:col>
            <:col :let={row} label="Status">{row.status}</:col>
            <:action>
              <.button variant="ghost" size="sm">Restart</.button>
            </:action>
          </.table>
        </section>

        <section class="grid gap-4">
          <h2 class="text-lg font-semibold">List</h2>
          <.list>
            <:item title="App">Phoenix 1.8</:item>
            <:item title="Database">PostgreSQL 17</:item>
            <:item title="Storage">SeaweedFS (S3)</:item>
          </.list>
        </section>
      </div>
    </Layouts.app>
    """
  end
end
