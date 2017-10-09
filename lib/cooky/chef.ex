defmodule Cooky.Chef do
  use GenServer

  alias Cooking.IngredientMap

  defmodule State do
    alias Cooking.IngredientMap

    defstruct ingredient_map: %{}

    def init(ingredients) do
      map = IngredientMap.from_ingredients(ingredients)
      %__MODULE__{ingredient_map: map}
    end

    def ingredients(state) do
      IngredientMap.ingredients(state.ingredient_map)
    end

    def select_ingredient(state, ingredient_id) do
      map = IngredientMap.select_ingredient(state.ingredient_map, ingredient_id)
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

  def reset(ingredients) do
    GenServer.call(__MODULE__, {:reset, ingredients})
  end

  def init([]) do
    ingredients = Cooking.all_ingredients()
    {:ok, State.init(ingredients)}
  end

  def handle_call(:ingredients, _from, state) do
    {:reply, State.ingredients(state), state}
  end

  def handle_call({:select_ingredient, ingredient_id}, _from, state) do
    state_out = State.select_ingredient(state, ingredient_id)
    {:reply, State.ingredients(state_out), state_out}
  end

  def handle_call({:reset, ingredients}, _from, _state) do
    {:reply, :ok, State.init(ingredients)}
  end
end
