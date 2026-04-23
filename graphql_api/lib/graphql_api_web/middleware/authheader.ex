defmodule GraphqlApiWeb.Middleware.Authheader do
  @behaviour Absinthe.Middleware
  #

  # If there is a role in the context
  @impl Absinthe.Middleware
  def call(%{context: %{"role" => auth_role}} = res, role: role) do
    # check if it is the same as the role in the middleware call
    if auth_role == role do
      res
    else
      # Halt the resolution
      Absinthe.Resolution.put_result(
        res,
        {:error, SharedUtils.Error.not_acceptable("permission: false", %{details: auth_role})}
      )
    end
  end

  # If there is no role in the context
  def call(res, _opts) do
    Absinthe.Resolution.put_result(
      res,
      {:error, SharedUtils.Error.not_acceptable("permission: false", %{details: "role: nil"})}
    )
  end
end
