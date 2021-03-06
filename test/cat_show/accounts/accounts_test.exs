defmodule CatShow.AccountsTest do
  use CatShow.DataCase

  alias CatShow.Accounts

  describe "users" do
    alias CatShow.Accounts.User

    @valid_attrs %{email: "some@email", name: "some name", password: "some password", roles: ["admin", "user"]}
    @update_attrs %{email: "some@updated email", name: "some updated name", password: "some updated password", roles: ["secretary"]}
    @invalid_attrs %{email: nil, name: nil, password_hash: nil, roles: nil}
    @no_role %{email: "email@site", name: "name", password_hash: "pwd", roles: []}
    @unknown_role %{email: "email@site", name: "name", password_hash: "pwd", roles: ["root", "admin"]}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email"
      assert user.name == "some name"
      assert Argon2.check_pass(user, "some password")
      assert user.roles == ["admin", "user"]
    end

    test "create_user/1 with valid dat creates a user" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.email == "some@email"
      assert user.name == "some name"
      assert Argon2.check_pass(user, "some password")
      assert user.roles == ["admin", "user"]
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@invalid_attrs)
    end

    test "create_user/1 with no roles returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@no_role)
    end

    test "create_user/1 with unknown roles returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user(@unknown_role)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Accounts.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some@updated email"
      assert user.name == "some updated name"
      assert Argon2.check_pass(user, "some password")
      assert user.roles == ["secretary"]
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 with no roles returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @no_role)
      assert user == Accounts.get_user!(user.id)
    end

    test "update_user/2 with unknown roles returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @unknown_role)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end

    test "change_password/2 with valid data updates user" do
      user = user_fixture()
      assert {:ok, updated} = Accounts.change_password(user, %{name: "new name", password: "new password", password2: "new password", old_password: "some password"})
      assert updated.name == user.name
      assert updated.password_hash != user.password_hash
    end

    test "change_password/2 with incorrect password returns error" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.change_password(user, %{password: "new password", password2: "new password", old_password: "wrong password"})
      assert user == Accounts.get_user!(user.id)
    end

    test "change_password/2 with not matching new passwords returns error" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.change_password(user, %{password: "new password", password2: "other password", old_password: "some password"})
      assert user == Accounts.get_user!(user.id)
    end

    test "change_password/2 with invalid new password returns error" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.change_password(user, %{password: "pwd", password2: "pwd", old_password: "some password"})
      assert user == Accounts.get_user!(user.id)
    end

    test "authenticate/2 with correct email and password returns user" do
      user = user_fixture()
      assert {:ok, user} == Accounts.authenticate(user.email, "some password")
    end

    test "authenticate/2 with unknown email returns error" do
      user = user_fixture()
      assert {:error, :invalid_credentials} == Accounts.authenticate(user.email <> "foo", "some password")
    end

    test "authenticate/2 with correct email and incorrect password returns error" do
      user = user_fixture()
      assert {:error, :invalid_credentials} == Accounts.authenticate(user.email, "some another password")
    end
  end
end
