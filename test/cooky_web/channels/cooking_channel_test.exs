defmodule CookyWeb.CookingChannelTest do
  use CookyWeb.ChannelCase

  alias Cooky.Chef
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

    # fails
    # Chef.reset_in_proc()
    Chef.reset

    ref = push socket, "select:ingredient", %{"ingredient_id" => "#{regular_batter.id}"}
    assert_reply ref, :ok, %{ok: true}

    assert_broadcast "select:ingredient", %{ingredients: [ingredient_after]}
    assert 1 == ingredient_after.selected_count
  end

  test "shout broadcasts to cooking:lobby", %{socket: socket} do
    push socket, "shout", %{"hello" => "all"}
    assert_broadcast "shout", %{"hello" => "all"}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end
end
