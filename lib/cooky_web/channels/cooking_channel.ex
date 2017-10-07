defmodule CookyWeb.CookingChannel do
  use CookyWeb, :channel

  alias Cooky.Chef

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
    ingredients = Chef.select_ingredient(ingredient_id)
    {:reply, {:ok, %{ingredients: ingredients}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (cooking:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
