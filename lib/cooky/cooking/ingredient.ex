defmodule Cooking.Ingredient do
  use Ecto.Schema

  schema "ingredients" do
    field :name, :string
    belongs_to :ingredient_type, Cooking.IngredientType
  end
end
