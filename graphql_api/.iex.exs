alias GraphqlApi.AccountFactory, as: AF
alias GraphqlApiWeb.Schema
alias GraphqlApi.Users
alias GraphqlApi.AuthPipe.{UserProducer, UserToken, UserStream}
alias GraphqlApi.Accounts.Timestamps
import Ecto.Query

IEx.configure(inspect: [limit: :infinity])
# pid = Ecto.Adapters.SQL.Sandbox.start_owner!(GraphqlApi.Repo, shared: true)
# Enum.each(AF.build_8(:account), &Users.create_user/1)
