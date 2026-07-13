defmodule GraphqlApi.Repo.Migrations.AddTableAuthpipe do
  use Ecto.Migration

  def change do
    create table(:timestamps, primary_key: false) do
      add :timestamp, :utc_datetime 
    end

  end
end
