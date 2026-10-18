defmodule ZykerWeb.UI.Form do
  @moduledoc """
  Form controls built on Base UI's Field anatomy: a `field` root holding a
  label, the control, an optional description and errors. The control is
  linked to its description and errors through `aria-describedby`, and
  `aria-invalid` / `data-invalid` drive the error styling.
  """
  use Phoenix.Component

  import ZykerWeb.UI.Icon

  @control "w-full min-w-0 rounded-md border border-input bg-transparent text-base shadow-xs transition-[color,box-shadow] outline-none placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground focus-visible:border-ring focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:border-destructive aria-invalid:ring-destructive/20 dark:bg-input/30 dark:aria-invalid:ring-destructive/40 md:text-sm"

  @controls %{
    "input" =>
      "#{@control} h-9 px-3 py-1 file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground",
    "select" => "#{@control} h-9 px-3 py-1",
    "textarea" => "#{@control} field-sizing-content min-h-16 px-3 py-2",
    "checkbox" =>
      "size-4 shrink-0 rounded-[4px] border-input accent-primary shadow-xs outline-none focus-visible:ring-[3px] focus-visible:ring-ring/50 disabled:cursor-not-allowed disabled:opacity-50 aria-invalid:outline aria-invalid:outline-destructive"
  }

  @doc """
  Renders a form field: label, control, description and errors.

  A `Phoenix.HTML.FormField` may be passed as `field`, which provides the
  id, name, value and errors (errors show once the input was used).
  Otherwise all attributes may be passed explicitly.

  `type` accepts any HTML input type plus `"select"` (with `options`,
  see `Phoenix.HTML.Form.options_for_select/2`), `"textarea"`, and
  `"checkbox"` for booleans. For live uploads use `live_file_input/1`.

  ## Examples

      <.input field={@form[:email]} type="email" label="Email" />
      <.input field={@form[:bio]} type="textarea" label="Bio" description="Shown on your profile." />
      <.input field={@form[:role]} type="select" label="Role" options={[Admin: "admin", User: "user"]} />
      <.input field={@form[:terms]} type="checkbox" label="I accept the terms" />
  """
  attr :id, :any, default: nil
  attr :name, :any
  attr :label, :string, default: nil
  attr :description, :string, default: nil
  attr :value, :any

  attr :type, :string,
    default: "text",
    values: ~w(checkbox color date datetime-local email file month number password
               search select tel text textarea time url week hidden)

  attr :field, Phoenix.HTML.FormField,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :errors, :list, default: []
  attr :checked, :boolean, doc: "the checked flag for checkbox inputs"
  attr :prompt, :string, default: nil, doc: "the prompt for select inputs"
  attr :options, :list, doc: "the options to pass to Phoenix.HTML.Form.options_for_select/2"
  attr :multiple, :boolean, default: false, doc: "the multiple flag for select inputs"
  attr :class, :any, default: nil, doc: "extra classes for the control"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step)

  def input(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    errors = if Phoenix.Component.used_input?(field), do: field.errors, else: []

    assigns
    |> assign(field: nil, id: assigns.id || field.id)
    |> assign(:errors, Enum.map(errors, &translate_error(&1)))
    |> assign_new(:name, fn -> if assigns.multiple, do: field.name <> "[]", else: field.name end)
    |> assign_new(:value, fn -> field.value end)
    |> input()
  end

  def input(%{type: "hidden"} = assigns) do
    ~H"""
    <input type="hidden" id={@id} name={@name} value={@value} {@rest} />
    """
  end

  def input(assigns) do
    assigns =
      assigns
      |> assign(:invalid, assigns.errors != [])
      |> assign(:describedby, describedby(assigns))

    ~H"""
    <div
      data-slot="field"
      data-invalid={@invalid}
      data-disabled={@rest[:disabled]}
      class={["group/field grid gap-2", @type == "checkbox" && "grid-cols-[auto_1fr] items-center"]}
    >
      <.label :if={@label && @type != "checkbox"} for={@id}>{@label}</.label>
      <.control {assigns} />
      <.label :if={@label && @type == "checkbox"} for={@id}>{@label}</.label>
      <p
        :if={@description}
        id={"#{@id}-description"}
        data-slot="field-description"
        class="col-span-full text-sm text-muted-foreground"
      >
        {@description}
      </p>
      <.field_error :for={msg <- @errors} id={"#{@id}-error"}>{msg}</.field_error>
    </div>
    """
  end

  defp control(%{type: "checkbox"} = assigns) do
    assigns =
      assign_new(assigns, :checked, fn ->
        Phoenix.HTML.Form.normalize_value("checkbox", assigns[:value])
      end)

    ~H"""
    <span class="contents">
      <input
        type="hidden"
        name={@name}
        value="false"
        disabled={@rest[:disabled]}
        form={@rest[:form]}
      />
      <input
        type="checkbox"
        id={@id}
        name={@name}
        value="true"
        checked={@checked}
        data-slot="field-control"
        aria-invalid={@invalid && "true"}
        aria-describedby={@describedby}
        class={[control_class("checkbox"), @class]}
        {@rest}
      />
    </span>
    """
  end

  defp control(%{type: "select"} = assigns) do
    ~H"""
    <select
      id={@id}
      name={@name}
      multiple={@multiple}
      data-slot="field-control"
      aria-invalid={@invalid && "true"}
      aria-describedby={@describedby}
      class={[control_class("select"), @multiple && "h-auto!", @class]}
      {@rest}
    >
      <option :if={@prompt} value="">{@prompt}</option>
      {Phoenix.HTML.Form.options_for_select(@options, @value)}
    </select>
    """
  end

  defp control(%{type: "textarea"} = assigns) do
    ~H"""
    <textarea
      id={@id}
      name={@name}
      data-slot="field-control"
      aria-invalid={@invalid && "true"}
      aria-describedby={@describedby}
      class={[control_class("textarea"), @class]}
      {@rest}
    >{Phoenix.HTML.Form.normalize_value("textarea", @value)}</textarea>
    """
  end

  defp control(assigns) do
    ~H"""
    <input
      type={@type}
      name={@name}
      id={@id}
      value={Phoenix.HTML.Form.normalize_value(@type, @value)}
      data-slot="field-control"
      aria-invalid={@invalid && "true"}
      aria-describedby={@describedby}
      class={[control_class("input"), @class]}
      {@rest}
    />
    """
  end

  defp describedby(%{id: nil}), do: nil

  defp describedby(assigns) do
    [
      assigns.description && "#{assigns.id}-description",
      assigns.errors != [] && "#{assigns.id}-error"
    ]
    |> Enum.filter(& &1)
    |> case do
      [] -> nil
      ids -> Enum.join(ids, " ")
    end
  end

  @doc """
  Returns the default classes for a bare control (`"input"`, `"select"`,
  `"textarea"` or `"checkbox"`), for controls rendered outside `input/1`.
  """
  def control_class(kind), do: Map.fetch!(@controls, kind)

  @doc """
  Renders a label. Dims itself when its field is disabled.
  """
  attr :for, :string, default: nil
  attr :class, :any, default: nil
  attr :rest, :global
  slot :inner_block, required: true

  def label(assigns) do
    ~H"""
    <label
      for={@for}
      data-slot="field-label"
      class={[
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-disabled/field:pointer-events-none group-data-disabled/field:opacity-50",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </label>
    """
  end

  @doc """
  Renders a field error message.
  """
  attr :id, :string, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  def field_error(assigns) do
    ~H"""
    <p
      id={@id}
      data-slot="field-error"
      class={["col-span-full flex items-center gap-1.5 text-sm text-destructive", @class]}
    >
      <.icon name="hero-exclamation-circle-mini" class="size-4" />
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # Error messages are generated dynamically, so they are translated by
    # calling Gettext with the backend and the "errors" domain.
    if count = opts[:count] do
      Gettext.dngettext(ZykerWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(ZykerWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end
end
