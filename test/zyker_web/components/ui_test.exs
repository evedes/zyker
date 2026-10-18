defmodule ZykerWeb.UITest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest
  use ZykerWeb.UI

  defp has?(html, selector) do
    html |> LazyHTML.from_fragment() |> LazyHTML.query(selector) |> Enum.any?()
  end

  describe "button/1" do
    test "renders a button with the variant exposed as data" do
      assigns = %{}
      html = rendered_to_string(~H|<.button variant="outline" size="sm">Save</.button>|)

      assert has?(html, ~s|button[data-slot="button"][data-variant="outline"].h-8|)
    end

    test "renders a link when given navigate" do
      assigns = %{}
      html = rendered_to_string(~H|<.button navigate="/home">Home</.button>|)

      assert has?(html, ~s|a[href="/home"][data-phx-link="redirect"][data-slot="button"]|)
    end
  end

  describe "input/1" do
    test "links the control to its label and description" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<.input id="email" name="email" value="" label="Email" description="We never share it." />|
        )

      assert has?(html, ~s|label[for="email"][data-slot="field-label"]|)
      assert has?(html, ~s|input#email[aria-describedby="email-description"]|)
      assert has?(html, ~s|p#email-description[data-slot="field-description"]|)
      refute has?(html, "[aria-invalid]")
    end

    test "marks the field invalid and links the error" do
      assigns = %{}

      html =
        rendered_to_string(
          ~H|<.input id="email" name="email" value="" errors={["is required"]} />|
        )

      assert has?(html, ~s|[data-slot="field"][data-invalid]|)
      assert has?(html, ~s|input#email[aria-invalid="true"][aria-describedby="email-error"]|)
      assert has?(html, ~s|p#email-error[data-slot="field-error"]|)
      assert html =~ "is required"
    end

    test "checkbox submits false when unchecked" do
      assigns = %{}
      html = rendered_to_string(~H|<.input id="t" name="terms" type="checkbox" value={false} />|)

      assert has?(html, ~s|input[type="hidden"][name="terms"][value="false"]|)
      assert has?(html, ~s|input#t[type="checkbox"][value="true"]:not([checked])|)
    end
  end
end
