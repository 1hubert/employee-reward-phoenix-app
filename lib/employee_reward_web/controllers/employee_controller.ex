defmodule EmployeeRewardWeb.EmployeeController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Repo
  alias EmployeeReward.Accounts.Employee

  def action(conn, _) do
    apply(__MODULE__, action_name(conn), [conn, conn.params, conn.assigns.current_employee])
  end

  def index(conn, _params, current_employee) do
     %{id: current_employee_id} = current_employee

    loaded_employee =
      Employee
      |> Repo.get!(current_employee_id)
      |>Repo.preload(:points_balance)

    points = %{
      to_grant: loaded_employee.points_balance.points_to_grant,
      obtained: loaded_employee.points_balance.points_obtained
    }

    employees = Repo.all(Employee)
    render(conn, "index.html", employees: employees, points: points)
  end

  def show(conn, params, _current_employee) do
    %{"id" => id} = params
    employee = Repo.get!(Employee, id)
    render(conn, "show.html", employee: employee)
  end
end
