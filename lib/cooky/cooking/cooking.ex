defmodule Cooking do
  alias Cooking.Ingredient
  alias Cooky.Repo

  import Ecto.Query

  def all_ingredients do
    Repo.all(from i in Ingredient, select: i)
  end
end
