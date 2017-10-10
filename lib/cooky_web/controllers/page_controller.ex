defmodule CookyWeb.PageController do
  use CookyWeb, :controller

  alias Cooking.Chef

  def index(conn, _params) do
    ingredients = Chef.ingredients
    render conn, "index.html", ingredients: ingredients
  end
end
