defmodule Batcher.BatchController do
  use Batcher.Web, :controller
  alias Batcher.App
  alias Batcher.Batch
  alias Batcher.Parallel

  def create(conn, %{"batch" => batch_params}) do
    changeset = Batch.changeset(%Batch{}, batch_params)

    case Repo.insert(changeset) do
      {:ok, batch} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", batch_path(conn, :show, batch))
        |> render("show.json", batch: batch)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Batcher.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def batch(conn, %{"_json" => requests}) do
    [given_api_key] = get_req_header(conn, "authorization")
    # try do
      Repo.one!(from a in App, where: a.api_key == ^given_api_key)
      res = Parallel.pmap(requests, fn(request) -> do_request(request) end)
      IO.inspect res
      json conn, res
    # rescue
    #   _ ->
    #     json conn, []
    # end
  end

  def do_request(request) do
    id = request["id"]
    url = request["url"]
    header = request["headers"]
    method = request["method"]
    body = request["body"]

    case method do
      "get" ->
         res = HTTPoison.get! url
         %{id: id, body: res.body, status: res.status_code}
      _ ->
        nil
    end
  end
end
