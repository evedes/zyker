defmodule ZykerWeb.UI do
  @moduledoc """
  Zyker's component library: Phoenix function components styled with
  Tailwind after [shadcn/ui](https://ui.shadcn.com) and structured after
  [Base UI](https://base-ui.com).

  Conventions every component follows:

    * Colors and radii come from the semantic design tokens in
      `assets/css/app.css` (`bg-primary`, `text-muted-foreground`,
      `border-input`, `rounded-md`, ...), never raw palette colors, so
      light and dark themes work without per-component changes.

    * The root element carries `data-slot="<component>"` (and sub-parts
      `data-slot="<component>-<part>"`) so parents can target parts with
      selectors such as `*:data-[slot=field-error]:mt-1`.

    * State is exposed as `data-*` and ARIA attributes (`aria-invalid`,
      `data-variant`, ...) and styled with the matching Tailwind variants
      instead of extra classes.

    * `class` is appended after the defaults. There is no class merging, so
      to override a default utility prefer the important modifier
      (`h-12!`).

  `use ZykerWeb.UI` imports every component; `ZykerWeb.html_helpers/0`
  does that for all views, live views and components.
  """

  defmacro __using__(_opts) do
    quote do
      import ZykerWeb.UI.Button
      import ZykerWeb.UI.Flash
      import ZykerWeb.UI.Form
      import ZykerWeb.UI.Header
      import ZykerWeb.UI.Icon
      import ZykerWeb.UI.JS
      import ZykerWeb.UI.Table
    end
  end
end
