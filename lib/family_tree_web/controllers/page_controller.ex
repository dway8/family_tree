defmodule FamilyTreeWeb.PageController do
  use FamilyTreeWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
