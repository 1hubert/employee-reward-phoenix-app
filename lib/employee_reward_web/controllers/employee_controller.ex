defmodule EmployeeRewardWeb.EmployeeController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Repo
  alias EmployeeReward.Accounts.Employee

  def index(conn, _params) do
    employees = Repo.all(Employee)
    render(conn, "index.html", employees: employees)
  end

  def show(conn, params) do
    %{"id" => id} = params
    employee = Repo.get!(Employee, id)
    render(conn, "show.html", employee: employee)
  end
end
