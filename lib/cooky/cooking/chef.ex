defmodule Cooking.Chef do
  use GenServer

  alias Cooking.IngredientMap

  defmodule State do
    alias Cooking.IngredientMap

    defstruct ingredient_map: %{}, recipes: []

    def init(ingredients, recipes) do
      map = IngredientMap.from_ingredients(ingredients)
      %__MODULE__{ingredient_map: map, recipes: recipes}
    end

    def ingredients(state) do
      IngredientMap.ingredients(state.ingredient_map)
    end

    def select_ingredient(state, ingredient_id) do
      map = IngredientMap.select_ingredient(state.ingredient_map, ingredient_id)
      %{state | ingredient_map: map}
    end

    def check_recipes(state) do
      state
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

  # makes the database query from the caller
  def reset do
    ingredients = Cooking.all_ingredients()
    recipes = Cooking.all_recipes()
    GenServer.call(__MODULE__, {:reset, ingredients, recipes})
  end

  def init([]) do
    ingredients = Cooking.all_ingredients()
    recipes = Cooking.all_recipes()
    {:ok, State.init(ingredients, recipes)}
  end

  def handle_call(:ingredients, _from, state) do
    {:reply, State.ingredients(state), state}
  end

  def handle_call({:select_ingredient, ingredient_id}, _from, state) do
    state_out = state
                |> State.select_ingredient(ingredient_id)
                |> State.check_recipes
    {:reply, State.ingredients(state_out), state_out}
  end

  def handle_call({:reset, ingredients, recipes}, _from, _state) do
    {:reply, :ok, State.init(ingredients, recipes)}
  end
end
