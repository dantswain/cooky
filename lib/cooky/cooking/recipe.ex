defmodule Cooking.Recipe do
  use Ecto.Schema

  schema "recipes" do
    field :name, :string
    has_many :recipe_ingredients, Cooking.RecipeIngredient
  end
end
