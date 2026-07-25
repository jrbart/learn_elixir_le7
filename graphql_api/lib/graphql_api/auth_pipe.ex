defmodule GraphqlApi.AuthPipe do
  alias GraphqlApi.Accounts
  alias GraphqlApi.Repo
  alias GraphqlApi.Users
  alias GraphqlApi.AuthPipe.UserTokenNotify
  alias GraphqlApi.AuthPipe.UserTokenPersist
  alias GraphqlApi.AuthPipe.{UserProducer, UserToken}
  alias GraphqlApi.Accounts.Timestamps
  alias GraphqlApi.TokenCache.CacheTable
  import Ecto.Query

  @doc """
  build the GenStage pipeline for updating user auth tokens
  Only returns when all stages finish
  """
  def run(users \\ nil) do
    # This should be done with a transaction...
    Repo.insert(%Accounts.Timestamps{timestamp: DateTime.utc_now(:second)})
    # Disable (and clear) cache
    CacheTable.disable_cache()

    users =
      case users do
        nil ->
          Users.all()
          |> Enum.map(fn user -> user.id end)

        _ ->
          users
      end

    # Producer is started with demand set to :accumulate 
    pids =
      [
        UserProducer.start_link(:ok, users),
        UserToken.start_link(:ok),
        UserTokenNotify.start_link(:ok),
        UserTokenPersist.start_link(:ok)
      ]

    # start_link does not return until the init/1 function has returned
    # so now we can set the Producer demand to :forward to start moving
    # events through the pipeline and be sure that all Consumers will
    # receive all the Broadcast tokens
    trap_exits = Process.flag(:trap_exit, true) # we want to catch all exits from the pipeline
    GenStage.demand(UserProducer, :forward)

    # Wait for pipeline to finish then enable cache
    # This prevents a race condition where an old token might get 
    # added to the cache while the new tokens are being generated
    # (maybe more simple to just clear the cache at the end of run?)
    SharedUtils.Logger.debug(__MODULE__, "waiting for authpipe HERE...")
    loop_exits(pids)
    Process.flag(:trap_exit, trap_exits) # we want to set the flag back to what it was

    SharedUtils.Logger.debug(__MODULE__,"authpipe done HERE...")
    CacheTable.enable_cache()
    
    SharedUtils.Logger.debug(__MODULE__,"run done HERE...")
  end

  def last_run do
    Repo.one(from(Timestamps, limit: 1, order_by: [desc: :timestamp]))
  end

  defp loop_exits([]) do
    SharedUtils.Logger.debug(__MODULE__,"no more pids")
  end

  defp loop_exits(pids) do
    receive do
      {x, y, z} ->
        SharedUtils.Logger.debug(__MODULE__,"message #{x} #{z}")
        loop_exits(Enum.reject(pids, fn {:ok, pid} -> pid == y end))
    after
      1000 -> SharedUtils.Logger.debug(__MODULE__,"message timeout")
    end
  end
end
