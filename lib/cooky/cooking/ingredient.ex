defmodule Cooking.Ingredient do
  use Ecto.Schema

  @derive {Poison.Encoder, only: [:id, :name, :selected_count]}

  schema "ingredients" do
    field :name, :string
    belongs_to :ingredient_type, Cooking.IngredientType

    field :selected_count, :integer, default: 0, virtual: true
  end
end
