defmodule CookyWeb.CookingChannelTest do
  use CookyWeb.ChannelCase

  alias Cooking.Chef
  alias Cooky.Fixture
  alias CookyWeb.CookingChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(CookingChannel, "cooking:lobby")

    {:ok, socket: socket}
  end

  test "select:ingredient updates the ingredient count", %{socket: socket} do
    batter = Fixture.create_ingredient_type("batter")
    regular_batter = Fixture.create_ingredient("regular batter", batter)

    Chef.reset

    ref = push socket, "select:ingredient", %{"ingredient_id" => "#{regular_batter.id}"}
    assert_reply ref, :ok, %{ok: true}

    assert_broadcast "status", broadcast_payload
    %{ingredients: [ingredient_after], cooking: []} = broadcast_payload
    assert 1 == ingredient_after.selected_count
  end

  test "select:ingredient broadcasts recipes that are satisfied", %{socket: socket} do
    batter = Fixture.create_ingredient_type("batter")
    filling = Fixture.create_ingredient_type("filling")

    regular_batter = Fixture.create_ingredient("regular batter", batter)
    _nuts = Fixture.create_ingredient("nuts", filling)

    regular_cookie = Fixture.create_recipe("nutty cookies", [{regular_batter, 1}])

    Chef.reset

    ref = push socket, "select:ingredient", %{"ingredient_id" => "#{regular_batter.id}"}
    assert_reply ref, :ok, %{ok: true}

    assert_broadcast "status", broadcast_payload
    %{ingredients: ingredients_after, cooking: [cooking]} = broadcast_payload

    assert 2 == length(ingredients_after)
    assert regular_cookie.name == cooking
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
