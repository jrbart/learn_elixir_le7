defmodule GraphqlApi.TokenCache.CacheTable do
  use GenServer

  alias GraphqlApi.Repo
  alias GraphqlApi.Accounts.UserToken
  import Ecto.Query

  # Startup (initialization)

  def start_link(_) do
    GenServer.start_link(__MODULE__, {:cache_off, nil}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    SharedUtils.Logger.info(__MODULE__, "Starting...")
    {:ok, {:cache_on, create_cache()}}
  end

  # Table is cleared when tokens are regenerated

  # Table can be locked prior to regenerating tokens so that 
  # it doesn't cause race condition where old token is cached
  # instead of new token

  # If ets table is locked - return database results
  # It token found - return token
  # Check database
  # if results - cache token and return it 
  # return error

  # Client API

  def get_token(id) do
    GenServer.call(__MODULE__, {:get_token, id})
  end

  def disable_cache() do
    GenServer.call(__MODULE__, :cache_off)
  end

  def enable_cache() do
    GenServer.call(__MODULE__, :cache_on)
  end

  # Callbacks

  @impl true
  def handle_call({:get_token, id}, _from, {:cache_off, nil} = state) do
    SharedUtils.Logger.debug(__MODULE__, "Get token #{id}")
    {:reply, token_from_db(id), state}
  end

  @impl true
  def handle_call({:get_token, id}, _from, {:cache_on, table} = state) do
    SharedUtils.Logger.debug(__MODULE__, "Get token #{id}")

    res =
      case :ets.lookup(table, id) do
        [] ->
          val = token_from_db(id)
          :ets.insert_new(table, {id, val})
          val

        [{_id, val}] ->
          val
      end

    {:reply, res, state}
  end

  @impl true
  def handle_call(:cache_on = status, _from, {:cache_off, nil} = _state) do
    {:reply, status, {status, create_cache()}}
  end

  @impl true
  def handle_call(:cache_off = status, _from, {:cache_on, table} = _state) do
    :ets.delete(table)
    {:reply, status, {status, nil}}
  end

  @impl true
  def handle_call(_, _, {status, _table} = state) do
    {:reply, status, state}
  end

  # Helpers

  defp create_cache() do
    :ets.new(__MODULE__, [:named_table, read_concurrency: true])
  end

  defp token_from_db(id) do
    token = Repo.one(from(UserToken, where: [user_id: ^id]))
    token.token
  end
end
