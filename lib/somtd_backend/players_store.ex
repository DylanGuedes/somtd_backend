defmodule SoM.PlayersStore do
  alias SoM.PlayersStore, as: PS

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def put(store, key, value) do
    Agent.update(store, fn(state) -> Map.put(state, key, value) end)
  end

  def get(store, key) do
    Agent.get(store, fn(state) -> Map.get(state, key) end)
  end
end
