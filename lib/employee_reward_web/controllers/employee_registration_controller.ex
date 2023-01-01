defmodule EmployeeRewardWeb.EmployeeRegistrationController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Accounts
  alias EmployeeReward.Accounts.Employee
  alias EmployeeRewardWeb.EmployeeAuth

  def new(conn, _params) do
    changeset = Accounts.change_employee_registration(%Employee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"employee" => employee_params}) do
    case Accounts.register_employee(employee_params) do
      {:ok, %{employee: employee}} ->
        conn
        |> put_flash(:info, "Registered successfully!")
        |> EmployeeAuth.log_in_employee(employee)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
