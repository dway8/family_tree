defmodule FamilyTreeWeb.PeopleResolver do
  require Logger

  def family(_root, _args, _info) do
    # champions = Champions.list_champions_lite()
    family = %{}
    {:ok, family}
  end
end
