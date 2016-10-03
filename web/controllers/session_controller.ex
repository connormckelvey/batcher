defmodule Batcher.SessionController do
  use Batcher.Web, :controller
  import Batcher.Auth, only: [block_authenticated_users: 2]

  plug :block_authenticated_users when action in [:new]

  def new(conn, _) do
    render conn, "new.html"
  end

  def create(conn, %{ "session" => %{"email" => email, "password" => pass}}) do
    case Batcher.Auth.login_by_email_and_pass(conn, email, pass, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome Back, #{email}")
        |> redirect(to: page_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Wrong email address or password")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Batcher.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end

end
