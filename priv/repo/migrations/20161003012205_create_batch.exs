defmodule Batcher.Repo.Migrations.CreateBatch do
  use Ecto.Migration

  def change do
    create table(:batches) do
      add :body, :string

      timestamps()
    end

  end
end
