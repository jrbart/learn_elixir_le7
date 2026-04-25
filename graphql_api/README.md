In our OTP Process and Testing Assignment, we created a resolver counter to add to our project, now, we're going to add an error system, and handle some of the errors that could come out of Postgres, so that we get a nice clean error from the GraphQL API. 



Error System

Our Error system should have the following methods:

'''
ErrorUtils.not_found("message", %{details: "here"})
ErrorUtils.internal_server_error_found("message", %{details: "here"})
ErrorUtils.not_acceptable("message", %{details: "here"})
ErrorUtils.conflict("message", %{details: "here"})
'''

For the `user(id: 1)` query we have, let's return one of these errors if the user isn't found, it should return

'''
%{
  code: :not_found,
  details: %{id: id}
}
'''

If we can also write tests for this module that would be great

New Migration

Second, we're going to add a new migration to our ecto database using `mix ecto.gen.migration` and we're going to use `add unique_index(:my_table, [:my_field])` to make user emails a unique field for the model. We'll also have to make sure to add our validations to our schema module. 



Changeset Middleware

Now that we have some potential errors from ecto, we're going to add in a changeset converter middleware to handle errors that could come up during User creation, or updates if there are conflicts from the email. These errors should return `conflict` code. Any changeset details should pass through and we should add `code: :bad_request` if it's not a conflict.

EctoShorts also returns `ErrorMessage` structs, so lets make sure we handle any of those being returned, and utilise `ErrorMessage.to_jsonable_map` to encode them into serialisable results. , Any other errors should return `internal_server_error` if they don't match something we're expecting.

Don't forget to add it to your middleware pipeline and write tests!

def middleware(middleware, _, %{identifier: identifier}) when identifier === :mutation do
  middleware ++ [MyApp.ChangesetMiddleware]
end
This should convert any errors from the creation or user updates into errors that can be passed to absinthe. 



Auth Middleware

We're also going to add an authentication middleware and only allowing access to the mutations through a secret key, make sure to write tests! 

middleware AuthMiddleware, secret_key: "Imsecret"


**Make sure you delete the _build and deps folder, and zip up your project in a ".zip" or ".tar.gz" before uploading, please also name your project project_my_name for example my_app_mika that way I can identify it easier.**



Estimated Turnaround Time: 3 Business Days
