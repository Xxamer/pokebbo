defmodule PokebboWeb.ErrorJSONTest do
  use PokebboWeb.ConnCase, async: true

  test "renders 404" do
    assert PokebboWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert PokebboWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
