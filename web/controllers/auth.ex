defmodule Batcher.Auth do
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  alias Phoenix.Controller
  alias Batcher.Router.Helpers

  def init(opts) do
    Keyword.fetch(opts, :repo)
  end

  def call(conn, { :ok, repo }) do
    user_id = get_session(conn, :user_id)
    user = user_id && repo.get(Batcher.User, user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_email_and_pass(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(Batcher.User, email: email)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def block_unauthenticated_users(conn, _) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> Controller.put_flash(:error, "You must be signed in to view this page")
      |> Controller.redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def block_authenticated_users(conn, _) do
    if conn.assigns.current_user do
      conn
      |> Controller.put_flash(:info, "You already have an account, silly.")
      |> Controller.redirect(to: Helpers.page_path(conn, :index))
    else
      conn
    end
  end
end
