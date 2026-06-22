defmodule GraphqlApi.Repo.Migrations.AddTokenTable do
  use Ecto.Migration

  def change do
    create table(:user_tokens) do
      add :token, :string, null: false

      add :user_id, references(:users, on_delete: :delete_all), null: false 
    end

    create index(:user_tokens, [:user_id], unique: true)

  end
end
