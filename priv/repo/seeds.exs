# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Cooky.Repo.insert!(%Cooky.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Cooking.IngredientType
alias Cooking.Ingredient
alias Cooking.Recipe
alias Cooking.RecipeIngredient

alias Cooky.Repo

ingredient_types = [
  %IngredientType{name: "batter"},
  %IngredientType{name: "filling"}
]
|> Enum.map(&Repo.insert!/1)

ingredient_type_ids = Enum.map(ingredient_types, fn(i) -> {i.name, i.id} end) |> Enum.into(%{})

ingredients = [
  %Ingredient{name: "Normal Batter", ingredient_type_id: ingredient_type_ids["batter"]},
  %Ingredient{name: "Peanut Butter Batter", ingredient_type_id: ingredient_type_ids["batter"]},
  %Ingredient{name: "Snickerdoodle Batter", ingredient_type_id: ingredient_type_ids["batter"]},
  %Ingredient{name: "Chocolate Chips", ingredient_type_id: ingredient_type_ids["filling"]},
  %Ingredient{name: "Reese's Pieces", ingredient_type_id: ingredient_type_ids["filling"]},
  %Ingredient{name: "White Chocolate", ingredient_type_id: ingredient_type_ids["filling"]}
]
|> Enum.map(&Repo.insert!/1)

ingredient_ids = Enum.map(ingredients, fn(i) -> {i.name, i.id} end) |> Enum.into(%{})

recipes = [
  %Recipe{
    name: "Chocolate Chip",
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Normal Batter"]},
      %RecipeIngredient{ingredient_id: ingredient_ids["Chocolate Chips"]}
    ]
  },
  %Recipe{
    name: "White Chocolate Chip",
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Normal Batter"]},
      %RecipeIngredient{ingredient_id: ingredient_ids["White Chocolate"]}
    ]
  },
  %Recipe{
    name: "Deluxe Chocolate Chip",
    cooling_time: 2_000,
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Normal Batter"]},
      %RecipeIngredient{ingredient_id: ingredient_ids["Chocolate Chips"], quantity: 2}
    ]
  },
  %Recipe{
    name: "Peanut Butter",
    cooking_time: 2_000,
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Peanut Butter Batter"]}
    ]
  },
  %Recipe{
    name: "Peanut Butter Chocolate Chip",
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Peanut Butter Batter"]},
      %RecipeIngredient{ingredient_id: ingredient_ids["Chocolate Chips"]}
    ]
  },
  %Recipe{
    name: "Peanut Butter Lovers",
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Peanut Butter Batter"]},
      %RecipeIngredient{ingredient_id: ingredient_ids["Reese's Pieces"]}
    ]
  },
  %Recipe{
    name: "No I Really Love Peanut Butter",
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Peanut Butter Batter"]},
      %RecipeIngredient{ingredient_id: ingredient_ids["Reese's Pieces"], quantity: 2}
    ]
  },
  %Recipe{
    name: "Snickerdoodle",
    recipe_ingredients: [
      %RecipeIngredient{ingredient_id: ingredient_ids["Snickerdoodle Batter"]}
    ]
  }
]
|> Enum.map(&Repo.insert!/1)
