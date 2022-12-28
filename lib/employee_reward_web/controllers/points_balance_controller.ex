defmodule EmployeeRewardWeb.PointsBalanceController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Rewards

  def grant(conn, %{"to_id" => to_id, "value" => value}) do
    case Integer.parse(value) do
      {value, _} ->
        from_id = conn.assigns.current_employee.id
        to_id = String.to_integer(to_id)

        case Rewards.grant_points(from_id, to_id, value) do
          {:ok, _} ->
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
