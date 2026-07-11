defmodule GraphqlApi.AuthPipeMockTest do
  use GraphqlApi.DataCase
  use Mimic.DSL
  alias GraphqlApi.AuthPipe.UserProducer
  alias GraphqlApi.AuthPipe.UserTokenPersist
  alias GraphqlApi.AuthPipe.UserTokenNotify
  alias GraphqlApi.AuthPipe.UserToken

  alias GraphqlApi.AccountFactory, as: AF
  alias GraphqlApi.Users

  # set to global because ProducerConsumers get called by Elixirs 
  # GenStage process, not by the producer itself, so I don't know
  # the specific PID that I need for a Mimic.allow call
  setup :set_mimic_global

  setup do
    # mock the handle_events calls to verify that they were called
    Mimic.expect(
      GraphqlApi.AuthPipe.UserTokenNotify, # module to mock
      :handle_events, # function to mock
      1, # arity
      fn # function to execute instead
        _, _, _ ->
          {:noreply, [], []} # this is what handle_events returns
      end
    )

    Mimic.expect(
      GraphqlApi.AuthPipe.UserTokenPersist,
      :handle_events,
      1,
      fn
        _, _, _ ->
          {:noreply, [], []}
      end
    )

    :ok
  end

  describe "generator pipes to consumers" do
    setup _ctx do
      test_user = AF.build(:account)
      {:ok, user} = Users.create_user(test_user)
      %{user: user.id}
    end

    test "consumers get events", ctx do
      user_id = ctx.user

      {:ok, pid} = UserProducer.start_link(:ok, [user_id])
      UserToken.start_link(:ok)
      UserTokenNotify.start_link(:ok)
      UserTokenPersist.start_link(:ok)

      # set the Producer demand to :forward to start moving events
      GenStage.demand(UserProducer, :forward)

      # make a delay to give time for the pipeline to run
      Process.sleep(300)

      assert [[[{^user_id, _token}], _caller, _state]] =
               Mimic.calls(&UserTokenNotify.handle_events/3)

      assert [[[{^user_id, _token}], _caller, _state]] =
               Mimic.calls(&UserTokenPersist.handle_events/3)

      # verify that all expect called were run
      assert Mimic.verify!(pid)
    end
  end
end
