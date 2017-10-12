defmodule Cooking.Chef do
  use GenServer

  alias Cooking.IngredientMap
  alias CookyWeb.CookingChannel

  defmodule State do
    alias Cooking.IngredientMap
    require Logger

    defstruct [
      ingredient_map: %{},
      recipes: [],
      cooking: %{},
      cooling: %{},
      ready: [],
      status_callback: nil
    ] 

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

    def register_status_callback(state, callback) do
      %{state | status_callback: callback}
    end

    def on_status(state = %State{status_callback: nil}), do: state
    def on_status(state) do
      state.status_callback.(status(state))
      state
    end

    def status(state) do
      %{
        ingredients: ingredients(state),
        cooking: Map.values(state.cooking),
        cooling: Map.values(state.cooling),
        ready: state.ready
      }
    end

    def check_recipes(state) do
      recipe_pool = Enum.shuffle(state.recipes)
      {ready_to_cook, updated_ingredient_map} = Cooking.check_recipes(
        state.ingredient_map,
        recipe_pool
      )
      now_cooking = start_cooking(ready_to_cook)
      %{
        state |
        ingredient_map: updated_ingredient_map,
        cooking: Map.merge(state.cooking, now_cooking)
      }
    end

    def done_cooking(state, ref) do
      {ready_to_cool, still_cooking} = Map.pop(state.cooking, ref)
      Logger.debug(fn ->
        "Done cooking: '#{ready_to_cool.name}' (#{inspect ref})"
      end)
      now_cooling = start_cooling(ready_to_cool)
      %{state | cooking: still_cooking, cooling: Map.merge(state.cooling, now_cooling)}
    end

    def done_cooling(state, ref) do
      {finished, still_cooling} = Map.pop(state.cooling, ref)
      Logger.debug(fn ->
        "Done cooling: '#{finished.name}' (#{inspect ref})"
      end)
      %{state | cooling: still_cooling, ready: [finished | state.ready]}
    end

    defp start_cooking(ready_to_cook) do
      ready_to_cook
      |> Enum.map(fn(recipe) ->
        task = timer_task(recipe.cooking_time, :done_cooking)
        Logger.debug(fn -> "Now cooking: '#{recipe.name}' (#{inspect task.ref})" end)
        {task.ref, recipe}
      end)
      |> Enum.into(%{})
    end

    defp start_cooling(recipe) do
      task = timer_task(recipe.cooling_time, :done_cooling)
      Logger.debug(fn ->
        "Now cooling: '#{recipe.name}' (#{inspect task.ref})"
      end)
      %{task.ref => recipe}
    end

    defp timer_task(duration, message) do
      Task.async(fn ->
        :timer.sleep(duration)
        message
      end)
    end
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def ingredients do
    GenServer.call(__MODULE__, :ingredients)
  end

  def status do
    GenServer.call(__MODULE__, :status)
  end

  def select_ingredient(ingredient_id) do
    GenServer.call(__MODULE__, {:select_ingredient, ingredient_id})
  end

  def register_status_callback(callback) when is_function(callback, 1) do
    GenServer.call(__MODULE__, {:register_status_callback, callback})
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

  def handle_call(:status, _from, state) do
    {:reply, State.status(state), state}
  end

  def handle_call(:ingredients, _from, state) do
    {:reply, State.ingredients(state), state}
  end

  def handle_call({:select_ingredient, ingredient_id}, _from, state) do
    state_out = state
                |> State.select_ingredient(ingredient_id)
                |> State.check_recipes
    {:reply, :ok, state_out}
  end

  def handle_call({:reset, ingredients, recipes}, _from, _state) do
    {:reply, :ok, State.init(ingredients, recipes)}
  end

  def handle_call({:register_status_callback, callback}, _from, state) do
    {:reply, :ok, State.register_status_callback(state, callback)}
  end

  def handle_info({ref, :done_cooking}, state) do
    state_out = state
                |> State.done_cooking(ref)
                |> State.on_status
    {:noreply, state_out}
  end

  def handle_info({ref, :done_cooling}, state) do
    state_out = state
                |> State.done_cooling(ref)
                |> State.on_status
    {:noreply, state_out}
  end

  def handle_info({:DOWN, _, _, _, :normal}, state) do
    {:noreply, state}
  end
end
