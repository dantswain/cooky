defmodule CookingTest do
  use Cooky.DataCase

  alias Cooking.IngredientMap
  alias Cooky.Fixture

  test "checking recipes - not enough ingredients" do
    batter_type = Fixture.create_ingredient_type("batter")
    filling_type = Fixture.create_ingredient_type("filling")

    batter = Fixture.create_ingredient("batter", batter_type)
    chips = Fixture.create_ingredient("chips of some sort", filling_type)
    nuts = Fixture.create_ingredient("brazil nuts", filling_type)

    recipe = Fixture.create_recipe("nutty cookies", [{batter, 1}, {nuts, 1}])

    ingredient_map = IngredientMap.from_ingredients([batter, chips, nuts])
    recipes = [recipe]

    assert {[], ingredient_map} == Cooking.check_recipes(ingredient_map, recipes)
  end

  test "checking recipes - simple match" do
    batter_type = Fixture.create_ingredient_type("batter")
    filling_type = Fixture.create_ingredient_type("filling")

    batter = Fixture.create_ingredient("batter", batter_type)
    chips = Fixture.create_ingredient("chips of some sort", filling_type)
    nuts = Fixture.create_ingredient("brazil nuts", filling_type)

    recipe = Fixture.create_recipe("boring cookies", [{batter, 1}])

    ingredient_map = [batter, chips, nuts]
                     |> IngredientMap.from_ingredients
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(chips.id)

    recipes = [recipe]

    expect_ingredient_map = ingredient_map
                            |> IngredientMap.deselect_ingredient(batter.id)

    assert {[recipe], expect_ingredient_map} ==
      Cooking.check_recipes(ingredient_map, recipes)
  end

  test "checking recipes - match same recipe twice" do
    batter_type = Fixture.create_ingredient_type("batter")
    filling_type = Fixture.create_ingredient_type("filling")

    batter = Fixture.create_ingredient("batter", batter_type)
    chips = Fixture.create_ingredient("chips of some sort", filling_type)
    nuts = Fixture.create_ingredient("brazil nuts", filling_type)

    recipe = Fixture.create_recipe("boring cookies", [{batter, 1}])

    ingredient_map = [batter, chips, nuts]
                     |> IngredientMap.from_ingredients
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(chips.id)

    recipes = [recipe]

    expect_ingredient_map = ingredient_map
                            |> IngredientMap.deselect_ingredient(batter.id)
                            |> IngredientMap.deselect_ingredient(batter.id)

    assert {[recipe, recipe], expect_ingredient_map} ==
      Cooking.check_recipes(ingredient_map, recipes)
  end

  test "checking recipes - don't overmatch" do
    batter_type = Fixture.create_ingredient_type("batter")
    filling_type = Fixture.create_ingredient_type("filling")

    batter = Fixture.create_ingredient("batter", batter_type)
    chips = Fixture.create_ingredient("chips of some sort", filling_type)
    nuts = Fixture.create_ingredient("brazil nuts", filling_type)

    boring_recipe = Fixture.create_recipe("boring cookies", [{batter, 1}])
    chips_recipe = Fixture.create_recipe("chips cookies", [{batter, 1}, {chips, 1}])
    super_chips_recipe = Fixture.create_recipe("super chips cookies", [{batter, 1}, {chips, 2}])

    ingredient_map = [batter, chips, nuts]
                     |> IngredientMap.from_ingredients
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(chips.id)
                     |> IngredientMap.select_ingredient(chips.id)

    recipes = [boring_recipe, chips_recipe, super_chips_recipe]

    {satisfied_recipes, updated_ingredient_map} =
      Cooking.check_recipes(ingredient_map, recipes)
    assert 2 == length(satisfied_recipes)

    Enum.each(updated_ingredient_map, fn({_id, ingredient}) ->
      assert ingredient.selected_count >= 0
    end)
  end

  test "checking recipes - match multiple recipes" do
    batter_type = Fixture.create_ingredient_type("batter")
    filling_type = Fixture.create_ingredient_type("filling")

    boring_batter = Fixture.create_ingredient("boring batter", batter_type)
    batter = Fixture.create_ingredient("batter", batter_type)
    chips = Fixture.create_ingredient("chips of some sort", filling_type)
    nuts = Fixture.create_ingredient("brazil nuts", filling_type)
    hair = Fixture.create_ingredient("hair", filling_type)

    boring_recipe = Fixture.create_recipe("boring cookies", [{boring_batter, 1}])
    nuts_recipe = Fixture.create_recipe("chips cookies", [{batter, 1}, {nuts, 1}])
    super_chips_recipe = Fixture.create_recipe("super chips cookies", [{batter, 1}, {chips, 2}])

    ingredient_map = [boring_batter, batter, chips, nuts, hair]
                     |> IngredientMap.from_ingredients
                     |> IngredientMap.select_ingredient(boring_batter.id)
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(nuts.id)
                     |> IngredientMap.select_ingredient(batter.id)
                     |> IngredientMap.select_ingredient(chips.id)
                     |> IngredientMap.select_ingredient(chips.id)
                     |> IngredientMap.select_ingredient(hair.id)

    recipes = [boring_recipe, nuts_recipe, super_chips_recipe]

    expect_ingredient_map = ingredient_map
                            |> IngredientMap.deselect_ingredient(boring_batter.id)
                            |> IngredientMap.deselect_ingredient(batter.id)
                            |> IngredientMap.deselect_ingredient(nuts.id)
                            |> IngredientMap.deselect_ingredient(batter.id)
                            |> IngredientMap.deselect_ingredient(chips.id)
                            |> IngredientMap.deselect_ingredient(chips.id)

    {satisfied_recipes, got_ingredient_map} =
      Cooking.check_recipes(ingredient_map, recipes)

    assert MapSet.new(satisfied_recipes) == MapSet.new(recipes)
    assert expect_ingredient_map == got_ingredient_map
  end
end
