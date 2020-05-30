defmodule CatShow.Auth.Guardian do
  use Guardian, otp_app: :cat_show

  alias CatShow.Accounts
  alias CatShow.Accounts.User

  def subject_for_token(%User{} = user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    user = Accounts.get_user!(id)
    {:ok, user}
  rescue
    Ecto.NoResultsError -> {:error, :resource_not_found}
  end
end
