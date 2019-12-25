defmodule FamilyTreeWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: App.Repo

  alias FamilyTreeWeb.PeopleResolver

  object :person do
    field(:id, non_null(:id))
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:sex, non_null(:string))
    field(:relationship_id, :id)
  end

  object :relationship do
    field(:id, non_null(:id))
    field(:children, non_null(list_of(non_null(:id))))
  end

  object :family do
    field(:people, non_null(list_of(non_null(:person))))
    field(:relationships, non_null(list_of(non_null(:relationship))))
  end

  query do
    field :family, non_null(:family) do
      arg(:last_name, non_null(:string))
      resolve(&PeopleResolver.family/3)
    end

    #
    # field :champion, non_null(:champion) do
    #   arg(:id, non_null(:id))
    #   resolve(&ChampionsResolver.get/2)
    # end
  end

  # mutation do
  # field :create_champion, type: :champion do
  #   arg(:first_name, non_null(:string))
  #   arg(:last_name, non_null(:string))
  #   arg(:sport, non_null(:string))
  #   arg(:is_member, non_null(:boolean))
  #
  #   resolve(&ChampionsResolver.create/2)
  # end
  # end

  # input_object :winner_params do
  #   field(:last_name, non_null(:string))
  #   field(:first_name, non_null(:string))
  #   field(:position, non_null(:integer))
  # end
end
