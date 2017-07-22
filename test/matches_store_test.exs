defmodule SoM.MatchesStoreTest do
  use ExUnit.Case, async: true

  alias SoM.MatchesStore, as: MS

  test "stores matches by key" do
    {:ok, store} = MS.start_link
    assert MS.get(store, "42WK") == nil
    match_status = %{player1: nil, player2: nil}
    MS.put(store, "42WK", match_status)
    assert MS.get(store, "42WK") == match_status
  end
end
