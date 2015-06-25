defmodule SimpleCache.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link __MODULE__, [], [name: __MODULE__]
  end

  def start_child(value, lease_time) do
    Supervisor.start_child __MODULE__, [value, lease_time]
  end

  def init([]) do
    children = [
      worker(SimpleCache.Element, [], restart: :temporary, shutdown: :brutal_kill)
    ]
    supervise children, strategy: :simple_one_for_one
  end
end
