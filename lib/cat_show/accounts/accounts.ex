defmodule CatShow.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias CatShow.Repo

  alias CatShow.Accounts.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
    |> filter_fields()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
    |> filter_fields()
  end

  @doc """
  Change password for a user

  ## Examples
      iex> change_password(user, %{password: "new password", password2: "new password", old_password: "oldpassword"})
      {:ok, %User()}

      iex> change_password(user, %{password: "new password", password2: "other password", old_password: "oldpassword"})
      {:error, %Ecto.Changeset{}}

      iex> change_password(user, %{password: "new password", password2: "new password", old_password: "invalid"})
      {:error, %Ecto.Changeset{}}
  """
  def change_password(%User{} = user, attrs) do
    user
    |> User.password_changeset(attrs) #%{password: pwd, password2: pwd2, old_password: old})
    |> Repo.update()
    |> filter_fields()
  end

  @doc """
  Deletes a User.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Authenticate user with given email and (plaintext) password

  ## Examples
      iex> authenticate("user@domain", "password")
      {:ok, %User{}}

      iex> authenticate("unknown@domain", "password")
      {:error, :invalid_credentials}

      iex> authenticate("user@domain", "invalid_passwd")
      {:error, :invalid_credentials}

  """
  @spec authenticate(String.t(), String.t()) :: {:ok, %User{}} | {:error, :invalid_credentials}
  def authenticate(email, password) do
    query = from u in User, where: u.email == ^email
    case Repo.one(query) do
      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}

      user ->
        if Argon2.verify_pass(password, user.password_hash) do
          {:ok, user}
        else
          {:error, :invalid_credentials}
        end
    end
  end

  defp filter_fields(%User{} = user) do
    %User{user | password: nil, password2: nil, old_password: nil}
  end

  defp filter_fields(result) do
    case result do
      {:ok, %User{} = user} ->
        {:ok, filter_fields(user)}
      _ ->
        result
    end
  end
end
