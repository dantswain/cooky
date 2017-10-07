defmodule Cooky.Chef do
  use GenServer

  defmodule State do
    defstruct ingredient_map: %{}

    def init_ingredient_map(state) do
      map = Cooking.all_ingredients()
            |> Enum.map(fn(i) -> {i.id, i} end)
            |> Enum.into(%{})

      %{state | ingredient_map: map}
    end

    def ingredients(state) do
      Map.values(state.ingredient_map)
    end

    def select_ingredient(state, ingredient_id) do
      map = Map.update(
        state.ingredient_map,
        ingredient_id,
        {:error_no_ingredient, ingredient_id},
        fn(i) -> %{i | selected_count: i.selected_count + 1} end)
      %{state | ingredient_map: map}
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def ingredients do
    GenServer.call(__MODULE__, :ingredients)
  end

  def select_ingredient(ingredient_id) do
    GenServer.call(__MODULE__, {:select_ingredient, ingredient_id})
  end

  def init([]) do
    {:ok, State.init_ingredient_map(%State{})}
  end

  def handle_call(:ingredients, _from, state) do
    {:reply, State.ingredients(state), state}
  end

  def handle_call({:select_ingredient, ingredient_id}, _from, state) do
    state_out = State.select_ingredient(state, ingredient_id)
    {:reply, State.ingredients(state_out), state_out}
  end
end
