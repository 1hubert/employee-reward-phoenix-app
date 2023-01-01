defmodule EmployeeRewardWeb.AdminSessionController do
  use EmployeeRewardWeb, :controller

  import EmployeeRewardWeb.AdminAuth

  plug :redirect_if_admin_is_authenticated when action in [:new, :create]
  plug :require_authenticated_admin when action in [:delete]

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => auth_params}) do
    password = auth_params["password"]
    case password == "12345" do
      true ->
        conn
        |> renew_session()
        |> put_session(:admin_session, true)
        |> put_flash(:info, "Logged in successfuly")
        |> redirect(to: Routes.admin_path(conn, :index))
      false ->
        conn
        |> put_flash(:error, "Incorrect password")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> renew_session()
    |> put_flash(:info, "Logged out successfuly from Admin Dashboard")
    |> redirect(to: Routes.employee_session_path(conn, :create))
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end
end
