defmodule Cooking do
  alias Cooking.Ingredient
  alias Cooking.IngredientMap
  alias Cooking.Recipe
  alias Cooky.Repo

  import Ecto.Query

  def all_ingredients do
    Repo.all(from i in Ingredient, select: i)
  end

  def all_recipes do
    Repo.all(from r in Recipe, select: r)
  end

  def check_recipes(ingredient_map, recipes) do
    check_recipes(ingredient_map, recipes, [])
  end

  defp check_recipes(ingredient_map, recipe_pool, acc) do
    case first_satisfied_recipe(ingredient_map, recipe_pool) do
      nil ->
        {acc, ingredient_map}
      satisfied_recipe ->
        updated_ingredient_map = deselect_recipe(ingredient_map, satisfied_recipe)
        check_recipes(updated_ingredient_map, recipe_pool, [satisfied_recipe | acc])
    end
  end

  defp first_satisfied_recipe(ingredient_map, recipes) do
    Enum.find(
      recipes,
      &(IngredientMap.satisfies_recipe?(ingredient_map, &1))
    )
  end

  defp deselect_recipe(ingredient_map, recipe) do
    Enum.reduce(
      used_ingredients(recipe),
      ingredient_map,
      fn({ingredient_id, qty}, ingredient_map_acc) ->
        IngredientMap.deselect_ingredient(ingredient_map_acc, ingredient_id, qty)
      end
    )
  end

  defp used_ingredients(recipe) do
    Enum.map(
      recipe.recipe_ingredients,
      fn(recipe_ingredient) ->
        {
          recipe_ingredient.ingredient_id,
          recipe_ingredient.quantity
        }
      end)
  end
end
