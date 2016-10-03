defmodule Batcher.BatchView do
  use Batcher.Web, :view

  def render("index.json", %{batches: batches}) do
    %{data: render_many(batches, Batcher.BatchView, "batch.json")}
  end

  def render("show.json", %{batch: batch}) do
    %{data: render_one(batch, Batcher.BatchView, "batch.json")}
  end

  def render("batch.json", %{batch: batch}) do
    %{id: batch.id,
      body: batch.body}
  end
end
