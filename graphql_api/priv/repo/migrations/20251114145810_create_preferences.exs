defmodule GraphqlApi.Repo.Migrations.CreatePreferences do
  use Ecto.Migration

  def change do
    create table(:preferences, primary_key: false) do
      add :likes_emails, :boolean, null: false
      add :likes_phone_calls, :boolean, null: false
      add :likes_faxes, :boolean, null: false

      add :user_id, references(:users, on_delete: :nothing), null: false
    end
    create index(:preferences, [:user_id])
  end
end
