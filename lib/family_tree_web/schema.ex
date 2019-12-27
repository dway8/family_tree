defmodule FamilyTreeWeb.Schema do
  use Absinthe.Schema
  use Absinthe.Ecto, repo: App.Repo

  alias FamilyTreeWeb.FamilyResolver

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
      resolve(&FamilyResolver.get_all/3)
    end

    #
    # field :champion, non_null(:champion) do
    #   arg(:id, non_null(:id))
    #   resolve(&ChampionsResolver.get/2)
    # end
  end

  mutation do
    field :create_spouse, type: non_null(:family) do
      arg(:person_id, non_null(:id))
      arg(:spouse, non_null(:spouse_params))

      resolve(&FamilyResolver.create_spouse/2)
    end

    field :create_child, type: non_null(:family) do
      arg(:relationship_id, non_null(:id))
      arg(:child, non_null(:child_params))

      resolve(&FamilyResolver.create_child/2)
    end
  end

  input_object :spouse_params do
    field(:last_name, non_null(:string))
    field(:first_name, non_null(:string))
    field(:sex, non_null(:string))
  end

  input_object :child_params do
    field(:first_name, non_null(:string))
    field(:sex, non_null(:string))
  end
end
