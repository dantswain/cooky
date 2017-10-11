defmodule Cooky.Fixture do
  alias Cooking.Ingredient
  alias Cooking.IngredientType
  alias Cooking.Recipe
  alias Cooking.RecipeIngredient

  alias Cooky.Repo
  import Ecto.Query

  def create_ingredient_type(name) do
    Repo.insert!(%IngredientType{name: name})
  end

  def create_ingredient(name, ingredient_type) do
    Repo.insert!(%Ingredient{name: name, ingredient_type_id: ingredient_type.id})
  end

  def create_recipe(name, ingredients) do
    recipe = Repo.insert!(%Recipe{name: name})

    for {ingredient, quantity} <- ingredients do
      Repo.insert!(
        %RecipeIngredient{
          recipe_id: recipe.id,
          ingredient_id: ingredient.id,
          quantity: quantity
        }
      )
    end

    Repo.one!(
      from r in Recipe,
      where: r.id == ^recipe.id,
      preload: [:recipe_ingredients]
    )
  end
end
