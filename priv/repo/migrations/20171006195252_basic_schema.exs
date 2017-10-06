defmodule Cooky.Repo.Migrations.BasicSchema do
  use Ecto.Migration

  def change do
    create table("ingredient_types") do
      add :name, :string, null: false
    end
    create index("ingredient_types", [:name], unique: true)

    create table("ingredients") do
      add :name, :string, null: false
      add :ingredient_type_id, references(:ingredient_types), null: false
    end
    create index("ingredients", [:name], unique: true)

    create table("recipes") do
      add :name, :string, null: false
    end
    create index("recipes", [:name], unique: true)

    create table("recipes_ingredients") do
      add :recipe_id, references(:recipes), null: false
      add :ingredient_id, references(:ingredients), null: false
      add :quantity, :integer, default: 1, null: false
    end
    create index("recipes_ingredients", [:recipe_id, :ingredient_id], unique: true)
  end
end
