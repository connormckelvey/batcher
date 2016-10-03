defmodule Batcher.UserController do
  use Batcher.Web, :controller
  import Batcher.Auth, only: [block_unauthenticated_users: 2, block_authenticated_users: 2]

  plug :block_unauthenticated_users when action in [:show]
  plug :block_authenticated_users when action in [:new]

  alias Batcher.User

  def index(conn, _params) do
    conn
    |> redirect(to: page_path(conn, :index))
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)

    case Repo.insert(changeset) do
      {:ok, user} ->
        conn
        |> Batcher.Auth.login(user)
        |> put_flash(:info, "#{user.email}, Your account was created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
