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
    case do_check_recipes(ingredient_map, recipe_pool) do
      {[], _} -> {acc, ingredient_map}
      {satisfied_recipes, updated_ingredient_map} ->
        check_recipes(updated_ingredient_map, recipe_pool, acc ++ satisfied_recipes)
    end
  end

  defp do_check_recipes(ingredient_map, recipes) do
    satisfied_recipes = Enum.filter(
      recipes,
      fn(recipe) ->
        Enum.all?(recipe.recipe_ingredients, fn(recipe_ingredient) ->
          ingredient_id = recipe_ingredient.ingredient_id
          ingredient = Map.get(ingredient_map, ingredient_id)
          ingredient.selected_count >= recipe_ingredient.quantity
        end)
      end
    )

    used_ingredients = satisfied_recipes
                       |> Enum.map(
                         fn(recipe) ->
                           Enum.map(
                             recipe.recipe_ingredients,
                             fn(recipe_ingredient) ->
                               {
                                 recipe_ingredient.ingredient_id,
                                 recipe_ingredient.quantity
                               }
                             end)
                         end
                       )
                       |> List.flatten

    updated_ingredient_map = Enum.reduce(
      used_ingredients,
      ingredient_map,
      fn({ingredient_id, qty}, ingredient_map_acc) ->
        IngredientMap.deselect_ingredient(ingredient_map_acc, ingredient_id, qty)
      end
    )

    {satisfied_recipes, updated_ingredient_map}
  end
end
