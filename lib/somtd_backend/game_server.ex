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
    {:noreply, state}
  end

  defp serve_action("join", args, client_conn, state) do
    store = Map.get(state, :ps)
    PS.put(ps, "player")
    IO.puts "Player joined!"
  end

  def parse_packet(data) do
    [action, args] = data |> List.to_string |> String.trim |> String.split(";")
    args = Poison.decode!(args)
    [action, args]
  end

  def handle_info({_, _socket}, state) do
    {:noreply, state}
  end

  def alert_players(state) do
    #send_pkg(state, {127, 0, 0, 1}, 21337, )
    #:gen_udp.send(server_socket, client_ip, client_port, "hi")
  end

  def send_pkg(state, host, port, pkg) do
    :gen_udp.send(state, host, port, pkg)
  end
end
