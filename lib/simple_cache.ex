defmodule SimpleCache do
  use Application

  def start(_type, _args) do
    case SimpleCache.Supervisor.start_link do
      {:ok, pid} -> {:ok, pid}
      other -> {:error, other}
    end
  end

  def stop(_state) do
    {:ok}
  end
end
