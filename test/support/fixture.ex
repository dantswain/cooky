defmodule Cooky.Fixture do
  alias Cooking.Ingredient
  alias Cooking.IngredientType
  alias Cooky.Repo

  def create_ingredient_type(name) do
    Repo.insert!(%IngredientType{name: name})
  end

  def create_ingredient(name, ingredient_type) do
    Repo.insert!(%Ingredient{name: name, ingredient_type_id: ingredient_type.id})
  end
end
