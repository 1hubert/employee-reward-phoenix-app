defmodule EmployeeRewardWeb.PointsBalanceController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Rewards
  alias EmployeeReward.Accounts.EmployeeNotifier
  alias EmployeeReward.Accounts.Employee
  alias EmployeeReward.Repo

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
end
