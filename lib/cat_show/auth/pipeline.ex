defmodule CatShow.Auth.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :cat_show,
    module: CatShow.Auth.Guardian,
    error_handler: CatShow.Auth.ErrorHandler

  plug(Guardian.Plug.VerifyHeader)
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
