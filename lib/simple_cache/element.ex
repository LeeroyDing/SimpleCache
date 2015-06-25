defmodule SimpleCache.Element do
  use GenServer

  @server __MODULE__
  @default_lease_time 60 * 60 * 24

  def start_link(value, lease_time) do
    GenServer.start_link __MODULE__, [value, lease_time]
  end

  def create(value, lease_time \\ @default_lease_time) do
    SimpleCache.Supervisor.start_child value, lease_time
  end

  def fetch(pid) do
    GenServer.call pid, :fetch
  end

  def replace(pid, value) do
    GenServer.cast pid, {:replace, value}
  end

  def delete(pid) do
    GenServer.cast pid, :delete
  end

  # Private

  defp time_left(_, :infinity), do: :infinity
  defp time_left(start_time, lease_time) do
    now = :calendar.local_time
    current_time = now |> :calendar.datetime_to_gregorian_seconds
    time_elapsed = current_time - start_time
    case lease_time - time_elapsed do
      time when time <= 0 -> 0
      time -> time * 1000
    end
  end

  # Callbacks

  def init([value, lease_time]) do
    now = :calendar.local_time
    start_time = now |> :calendar.datetime_to_gregorian_seconds
    {:ok, %{value: value, lease_time: lease_time, start_time: start_time}, time_left(start_time, lease_time)}
  end

  def handle_call(:fetch, _from, %{value: value, lease_time: lease_time, start_time: start_time} = state) do
    time_left = time_left(start_time, lease_time)
    {:reply, {:ok, value}, state, time_left}
  end

  def handle_cast({:replace, value}, %{lease_time: lease_time, start_time: start_time} = state) do
    time_left = time_left(start_time, lease_time)
    {:noreply, %{state | value: value}, time_left}
  end

  def handle_cast(:delete, state) do
    {:stop, :normal, state}
  end

  def handle_info(:timeout, state) do
    {:stop, :normal, state}
  end

  def terminate(_reason, _state) do
    SimpleCache.Store.delete self
    :ok
  end

  def code_change(_old_vsn, state, _extra) do
    {:ok, state}
  end
end
