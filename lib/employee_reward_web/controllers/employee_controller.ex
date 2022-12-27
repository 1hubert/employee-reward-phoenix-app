defmodule EmployeeRewardWeb.EmployeeController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Repo
  alias EmployeeReward.Accounts.Employee

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_employee])
  end

  def index(conn, _params, %{id: current_employee_id}) do
    current_employee =
      Employee
      |> Repo.get!(current_employee_id)
      |> Repo.preload(:points_balance)

    employee_info = %{
      id: current_employee.id,
      points_to_grant: current_employee.points_balance.points_to_grant,
      points_obtained: current_employee.points_balance.points_obtained
    }

    employees = Repo.all(Employee)
    render(conn, "index.html", employees: employees, employee_info: employee_info)
  end

  def show(conn, params, _current_employee) do
    %{"id" => id} = params
    employee = Repo.get!(Employee, id)
    render(conn, "show.html", employee: employee)
  end
end
