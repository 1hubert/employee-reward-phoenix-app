defmodule EmployeeRewardWeb.PointsBalanceController do
  use EmployeeRewardWeb, :controller

  import EmployeeRewardWeb.AdminAuth

  alias EmployeeReward.Rewards
  alias EmployeeReward.Accounts.EmployeeNotifier
  alias EmployeeReward.Accounts.Employee
  alias EmployeeReward.Repo

  plug :require_authenticated_admin when action in [:edit, :update]

  def grant(conn, %{"to_id" => to_id, "value" => value}) do
    case Integer.parse(value) do
      {value, _} ->
        from_id = conn.assigns.current_employee.id
        to_id = String.to_integer(to_id)

        case Rewards.grant_points(from_id, to_id, value) do
          {:ok, _} ->
            sender = Repo.get!(Employee, from_id)
            employee = Repo.get!(Employee, to_id)
            EmployeeNotifier.deliver_received_points_notification(employee, value, sender)

            conn
            |> redirect(to: Routes.employee_path(conn, :index))
          {:error, message} ->
            conn
            |> put_flash(:error, message)
            |> redirect(to: Routes.employee_path(conn, :index))
        end
      :error ->
        conn
        |> put_flash(:error, "Provided value for points must be an integer")
        |> redirect(to: Routes.employee_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    balance = Rewards.get_points_balance!(id)
    changeset = Rewards.change_points_balance(balance)
    render(conn, "edit.html", points_balance: balance, changeset: changeset)
  end

  def update(conn, %{"id" => id, "points_balance" => balance_params}) do
    balance = Rewards.get_points_balance!(id)

    case Rewards.update_points_balance(balance, balance_params) do
      {:ok, _balance} ->
        conn
        |> put_flash(:info, "Employee balance updated successfully.")
        |> redirect(to: Routes.admin_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", points_balance: balance, changeset: changeset)
    end
  end
end
