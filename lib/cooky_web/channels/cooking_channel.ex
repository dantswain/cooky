defmodule CookyWeb.CookingChannel do
  use CookyWeb, :channel

  alias Cooking.Chef

  def broadcast_status!(status) do
    CookyWeb.Endpoint.broadcast! "cooking:lobby", "status", status_payload(status)
  end

  def join("cooking:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
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

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (cooking:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  defp status_payload(status) do
    %{
      ingredients: status.ingredients,
      cooking: Enum.map(status.cooking, fn(r) -> r.name end),
      cooling: Enum.map(status.cooling, fn(r) -> r.name end),
      ready: Enum.map(status.ready, fn(r) -> r.name end)
    }
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
