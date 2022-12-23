defmodule EmployeeRewardWeb.EmployeeController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Roles
  alias EmployeeReward.Roles.Employee

  def index(conn, _params) do
    employees = Roles.list_employees()
    render(conn, "index.html", employees: employees)
  end

  def register(conn, _params) do
    changeset = Roles.change_employee(%Employee{})
    render(conn, "register.html", changeset: changeset)
  end

  def create(conn, %{"employee" => employee_params}) do
    case Roles.create_employee(employee_params) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "Registered successfuly!")
        |> redirect(to: Routes.employee_path(conn, :show, employee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "register.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    employee = Roles.get_employee!(id)
    render(conn, "show.html", employee: employee)
  end

  def edit(conn, %{"id" => id}) do
    employee = Roles.get_employee!(id)
    changeset = Roles.change_employee(employee)
    render(conn, "edit.html", employee: employee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "employee" => employee_params}) do
    employee = Roles.get_employee!(id)

    case Roles.update_employee(employee, employee_params) do
      {:ok, employee} ->
        conn
        |> put_flash(:info, "Employee updated successfully.")
        |> redirect(to: Routes.employee_path(conn, :show, employee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", employee: employee, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    employee = Roles.get_employee!(id)
    {:ok, _employee} = Roles.delete_employee(employee)

    conn
    |> put_flash(:info, "Employee deleted successfully.")
    |> redirect(to: Routes.employee_path(conn, :index))
  end
end
