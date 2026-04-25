defmodule GraphqlApiWeb.AuthPlug do
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _) do
    context = build_context(conn)
    Absinthe.Plug.put_options(conn, context: context)
  end

  def build_context(conn) do
    with token <- get_req_header(conn, "authorization"),
         true <- authorize?(token) do
      SharedUtils.Logger.debug(__MODULE__, "Auth header detected")
      %{role: :admin}
    else
      _ -> %{}
    end
  end

  defp authorize?(token) do
    {:ok, token} == Application.fetch_env(GraphqlApiWeb.AuthPlug, :token)
  end
end
