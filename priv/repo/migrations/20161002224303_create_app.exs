defmodule Batcher.Repo.Migrations.CreateApp do
  use Ecto.Migration

  def change do
    create table(:apps) do
      add :name, :string
      add :api_key, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end
    create index(:apps, [:user_id])

  end
end
