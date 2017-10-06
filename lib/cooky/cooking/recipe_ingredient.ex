defmodule Cooking.RecipeIngredient do
  use Ecto.Schema

  schema "recipes_ingredients" do
    belongs_to :recipe, Cooking.Recipe
    belongs_to :ingredient, Cooking.Ingredient
    field :quantity, :integer, default: 1
  end
end
