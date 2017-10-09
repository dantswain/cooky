defmodule Cooking.IngredientMap do
  alias Cooking.Ingredient

  def from_ingredients(ingredients) do
    ingredients
    |> Enum.map(fn(i) -> {i.id, i} end)
    |> Enum.into(%{})
  end

  def ingredients(ingredient_map), do: Map.values(ingredient_map)

  def select_ingredient(ingredient_map, ingredient_id) do
    {:ok, ingredient} = Map.fetch(ingredient_map, ingredient_id)
    Map.put(ingredient_map, ingredient_id, Ingredient.select(ingredient))
  end
end
