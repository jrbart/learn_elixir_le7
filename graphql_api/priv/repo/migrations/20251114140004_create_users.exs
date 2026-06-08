defmodule GraphqlApi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :text
      add :email, :text

    end

    create index(:users, [:email], unique: true)
  end
end
