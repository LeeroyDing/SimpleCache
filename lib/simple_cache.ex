defmodule SimpleCache do
  use Application

  def start(_type, _args) do
    SimpleCache.Store.init
    case SimpleCache.Supervisor.start_link do
      {:ok, pid} -> {:ok, pid}
      other -> {:error, other}
    end
  end

  def stop(_state) do
    {:ok}
  end

  def insert(key, value) do
    case SimpleCache.Store.lookup key do
      {:ok, pid} -> SimpleCache.Element.replace pid, value
      {:error, :not_found} ->
        {:ok, pid} = SimpleCache.Element.create value
        SimpleCache.Store.insert key, pid
    end
  end

  def lookup(key) do
    try do
      {:ok, pid} = SimpleCache.Store.lookup key
      {:ok, value} = SimpleCache.Element.fetch pid
      {:ok, value}
    catch
      msg -> msg
    end
  end

  def delete(key) do
    case SimpleCache.Store.lookup(key) do
      {:ok, pid} -> SimpleCache.Element.delete pid
      {:error, _reason} -> :ok
    end
  end
end
