defmodule FamilyTreeWeb.Router do
  use FamilyTreeWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FamilyTreeWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # graphql API scope
  scope "/elixir" do
    forward("/graphql", Absinthe.Plug, schema: FamilyTreeWeb.Schema)
  end

  scope "/elixir" do
    pipe_through :api

    forward "/graphiql", Absinthe.Plug.GraphiQL,
      schema: FamilyTreeWeb.Schema,
      interface: :simple,
      context: %{pubsub: FamilyTreeWeb.Endpoint}
  end

  # Other scopes may use custom stacks.
  # scope "/api", FamilyTreeWeb do
  #   pipe_through :api
  # end
end
