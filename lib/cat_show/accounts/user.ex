defmodule CatShow.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string
    field :name, :string
    field :password_hash, :string
    field :roles, {:array, :string}

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password_hash, :roles])
    |> validate_required([:name, :email, :password_hash, :roles])
    |> unique_constraint(:email)
    |> validate_length(:roles, min: 1)
    |> validate_subset(:roles, ["admin", "secretary", "user"])
  end
end
