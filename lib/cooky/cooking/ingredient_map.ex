defmodule Cooking.IngredientMap do
  alias Cooking.Ingredient

  def from_ingredients(ingredients) do
    ingredients
    |> Enum.map(fn(i) -> {i.id, i} end)
    |> Enum.into(%{})
  end

  def ingredients(ingredient_map), do: Map.values(ingredient_map)

  def update_ingredient(ingredient_map, ingredient_id, updater) 
  when is_function(updater, 1) do
    {:ok, ingredient} = Map.fetch(ingredient_map, ingredient_id)
    Map.put(ingredient_map, ingredient_id, updater.(ingredient))
  end

  def select_ingredient(ingredient_map, ingredient_id) do
    update_ingredient(ingredient_map, ingredient_id, &Ingredient.select/1)
  end

  def deselect_ingredient(ingredient_map, ingredient_id, n \\ 1) do
    update_ingredient(ingredient_map, ingredient_id, &(Ingredient.deselect(&1, n)))
  end
end
