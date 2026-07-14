IO.inspect("Testing is starting")
# Mock testing for the database
Mimic.copy(GraphqlApi.Repo)

# Mock testing for the AuthToken pipelin
Mimic.copy(GraphqlApi.AuthPipe.UserTokenNotify)
Mimic.copy(GraphqlApi.AuthPipe.UserTokenPersist)

ExUnit.start()
