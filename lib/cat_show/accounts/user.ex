defmodule CatShow.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :email, :string, null: false
    field :name, :string, null: false
    field :password, :string, virtual: true
    field :password2, :string, virtual: true
    field :old_password, :string, virtual: true
    field :password_hash, :string, null: false
    field :roles, {:array, :string}, null: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :roles])
    |> validate_required([:name, :email, :roles])
    |> unique_constraint(:email)
    |> validate_length(:name, min: 2, max: 255)
    |> validate_length(:email, min: 3, max: 255)
    |> validate_format(:email, ~r/@/)
    |> validate_length(:roles, min: 1)
    |> validate_subset(:roles, ["admin", "secretary", "user"])
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8, max: 100)
    |> put_password_hash()
  end

  def password_changeset(user, attrs) do
    user
    |> cast(attrs, [:old_password, :password, :password2])
    |> validate_required([:old_password, :password, :password2])
    |> validate_length(:password, min: 8, max: 100)
    |> validate_passwords()
    |> put_password_hash()
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))

      _ -> changeset
    end
  end

  defp validate_passwords(changeset) do
    changeset
    |> validate_change(:old_password, {:old_password, "invalid password"}, fn _, value ->
      if Argon2.verify_pass(value, get_field(changeset, :password_hash)),
      do: [],
      else: [{:old_password, {"invalid password", [validation: :check_password, enum: ""]}}]
    end)
    |> validate_change(:password2, {:password2, "passwords mismatch"}, fn _, value ->
      case get_field(changeset, :password) do
        ^value ->
          []

        _ ->
          [{:password2, {"passwords mismatch", [validation: :compare_passwords, enum: ""]}}]
      end
    end)
  end
end
