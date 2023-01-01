defmodule EmployeeRewardWeb.AdminAuth do
  import Plug.Conn
  import Phoenix.Controller

  alias EmployeeRewardWeb.Router.Helpers, as: Routes

  def redirect_if_admin_is_authenticated(conn, _opts) do
    if get_session(conn, :admin_session) do
      conn
      |> redirect(to: Routes.admin_path(conn, :index))
      |> halt()
    else
      conn
    end
  end

  def require_authenticated_admin(conn, _opts) do
    if get_session(conn, :admin_session) do
      conn
    else
      conn
      |> put_flash(:error, "You need to be logged in as admin to access that page")
      |> redirect(to: Routes.admin_session_path(conn, :new))
    end
  end
end
