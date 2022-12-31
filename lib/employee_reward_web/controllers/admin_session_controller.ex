defmodule EmployeeRewardWeb.AdminSessionController do
  use EmployeeRewardWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"session" => auth_params}) do
    password = auth_params["password"]
    case password == "12345" do
      true ->
        conn
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
    |> delete_session(:admin_session)
    |> put_flash(:info, "Logged out successfuly")
    |> redirect(to: Routes.employee_session_path(conn, :create))
  end
end
