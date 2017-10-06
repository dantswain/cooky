defmodule Cooking.IngredientType do
  use Ecto.Schema

  schema "ingredient_types" do
    field :name, :string
  end
end
