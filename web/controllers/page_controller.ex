defmodule Batcher.PageController do
  use Batcher.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
