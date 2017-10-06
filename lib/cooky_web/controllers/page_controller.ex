defmodule CookyWeb.PageController do
  use CookyWeb, :controller

  def index(conn, _params) do
    ingredients = Cooking.all_ingredients
    render conn, "index.html", ingredients: ingredients
  end
end
