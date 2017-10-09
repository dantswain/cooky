defmodule Cooking.Recipe do
  use Ecto.Schema

  schema "recipes" do
    field :name, :string
    field :cooking_time, :integer
    field :cooling_time, :integer
    has_many :recipe_ingredients, Cooking.RecipeIngredient
  end
end
