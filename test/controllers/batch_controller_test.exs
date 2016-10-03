defmodule Batcher.BatchControllerTest do
  use Batcher.ConnCase

  alias Batcher.Batch
  @valid_attrs %{body: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, batch_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    batch = Repo.insert! %Batch{}
    conn = get conn, batch_path(conn, :show, batch)
    assert json_response(conn, 200)["data"] == %{"id" => batch.id,
      "body" => batch.body}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, batch_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, batch_path(conn, :create), batch: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Batch, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, batch_path(conn, :create), batch: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    batch = Repo.insert! %Batch{}
    conn = put conn, batch_path(conn, :update, batch), batch: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Batch, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    batch = Repo.insert! %Batch{}
    conn = put conn, batch_path(conn, :update, batch), batch: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    batch = Repo.insert! %Batch{}
    conn = delete conn, batch_path(conn, :delete, batch)
    assert response(conn, 204)
    refute Repo.get(Batch, batch.id)
  end
end
