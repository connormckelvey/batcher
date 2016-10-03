defmodule Batcher.Router do
  use Batcher.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Batcher.Auth, repo: Batcher.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Batcher do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :new, :create]
    resources "/session", SessionController
  end

  scope "/manage", Batcher do
    pipe_through :browser

    get "/", PageController, :index
    resources "/apps", AppController
  end

  scope "/api/v1", Batcher do
    pipe_through :api

    post "/batch", BatchController, :batch
  end

  # Other scopes may use custom stacks.
  # scope "/api", Batcher do
  #   pipe_through :api
  # end
end
