defmodule SoM.GameServer do
  use GenServer

  alias SoM.MatchesStore, as: MS
  alias SoM.PlayersStore, as: PS

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def init(:ok) do
    {:ok, server} = :gen_udp.open(21337)
    {:ok, ps} = PS.start_link

    initial_state = %{server: server, ps: ps}

    {:ok, initial_state}
  end

  def handle_info({:udp, client_socket, client_ip, client_port, data}, state) do
    [action, args] = parse_packet(data)
    serve_action(action, args, {client_socket, client_ip, client_port}, state)
  end

  defp serve_action("join", args, client_conn, state) do
    ps = Map.get(state, :ps)
    player_uuid = UUID.uuid1
    ps = PS.put(ps, player_uuid, %{conn: client_conn})
    {:noreply, state}
  end

  def parse_packet(data) do
    [action, args] = data |> List.to_string |> String.trim |> String.split(";")
    args = Poison.decode!(args)
    [action, args]
  end

  def handle_cast({:alert_players, msg}, state) do
    ps = Map.get(state, :ps)
    players = PS.all(ps)
    server = Map.get(state, :server)

    alert = fn(player) ->
      {uuid, player_info} = player
      {_socket, client_ip, client_port} = Map.get(player_info, :conn)
      :gen_udp.send(server, client_ip, client_port, msg)
    end
    Enum.each(players, alert)
    {:noreply, state}
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  def alert_players(pid, msg) do
    GenServer.cast(pid, {:alert_players, msg})
  end

  def send_pkg(state, host, port, pkg) do
    :gen_udp.send(state, host, port, pkg)
  end
end
