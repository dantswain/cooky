defmodule CookyWeb.CookingChannel do
  use CookyWeb, :channel

  alias Cooking.Chef

  def broadcast_status!(status) do
    CookyWeb.Endpoint.broadcast! "cooking:lobby", "status", status_payload(status)
  end

  def join("cooking:lobby", _payload, socket) do
    {:ok, socket}
  end

  def handle_in(
    "select:ingredient",
    %{"ingredient_id" => ingredient_id},
    socket
  ) do
    ingredient_id = String.to_integer(ingredient_id)
    Chef.select_ingredient(ingredient_id)
    status = Chef.status()

    broadcast socket, "status", status_payload(status)
    {:reply, {:ok, %{ok: true}}, socket}
  end

  defp status_payload(status) do
    %{
      ingredients: status.ingredients,
      cooking: Enum.map(status.cooking, fn(r) -> r.name end),
      cooling: Enum.map(status.cooling, fn(r) -> r.name end),
      ready: Enum.map(status.ready, fn(r) -> r.name end)
    }
  end
end
