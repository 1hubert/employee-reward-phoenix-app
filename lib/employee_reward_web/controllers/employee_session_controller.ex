defmodule EmployeeRewardWeb.EmployeeSessionController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Accounts
  alias EmployeeRewardWeb.EmployeeAuth

  def new(conn, _params) do
    render(conn, "new.html", error_message: nil)
  end

  def create(conn, %{"employee" => employee_params}) do
    %{"email" => email, "password" => password} = employee_params

    if employee = Accounts.get_employee_by_email_and_password(email, password) do
      EmployeeAuth.log_in_employee(conn, employee, employee_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      render(conn, "new.html", error_message: "Invalid email or password")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> EmployeeAuth.log_out_employee()
  end
end
