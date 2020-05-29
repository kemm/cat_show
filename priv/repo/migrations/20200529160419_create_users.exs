defmodule CatShow.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :password_hash, :string, null: false
      add :roles, {:array, :string}

      timestamps()
    end

    create unique_index(:users, [:email])
  end
end
