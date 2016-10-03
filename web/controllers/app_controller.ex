defmodule Batcher.AppController do
  use Batcher.Web, :controller
  import Ecto.Query
  alias Batcher.App

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_user])
  end

  def user_apps(user) do
    assoc(user, :apps)
  end

  def user_app(user, id) do
    Repo.get!(user_apps(user), id)
  end

  def index(conn, _params, user) do
    apps = user_apps(user) |> Repo.all
    render(conn, "index.html", apps: apps)
  end

  def new(conn, _params, user) do
    changeset = user
    |> build_assoc(:apps)
    |> App.changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"app" => app_params}, user) do
    changeset =
      user
      |> build_assoc(:apps)
      |> App.app_creation_changeset(app_params)

    case Repo.insert(changeset) do
      {:ok, _app} ->
        conn
        |> put_flash(:info, "App created successfully.")
        |> redirect(to: app_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}, user) do
    app = user_app(user, id)
    render(conn, "show.html", app: app)
  end

  def edit(conn, %{"id" => id}, user) do
    app = user_app(user, id)
    changeset = App.changeset(app)
    render(conn, "edit.html", app: app, changeset: changeset)
  end

  def update(conn, %{"id" => id, "app" => app_params}, user) do
    app = user_apps(user) |> Repo.get!(id)
    changeset = App.changeset(app, app_params)

    case Repo.update(changeset) do
      {:ok, app} ->
        conn
        |> put_flash(:info, "App updated successfully.")
        |> redirect(to: app_path(conn, :show, app))
      {:error, changeset} ->
        render(conn, "edit.html", app: app, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, user) do
    app = user_app(user, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(app)

    conn
    |> put_flash(:info, "App deleted successfully.")
    |> redirect(to: app_path(conn, :index))
  end
end
