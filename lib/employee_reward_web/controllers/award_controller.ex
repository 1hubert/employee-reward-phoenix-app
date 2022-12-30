defmodule EmployeeRewardWeb.AwardController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.{Repo, Rewards}
  alias EmployeeReward.Rewards.Award
  alias EmployeeReward.Accounts.Employee

  def index(conn, _params) do
    current_employee =
      Employee
      |> Repo.get!(conn.assigns.current_employee.id)
      |> Repo.preload(:points_balance)

    employee_info = %{
      id: current_employee.id,
      points_to_grant: current_employee.points_balance.points_to_grant,
      points_obtained: current_employee.points_balance.points_obtained
    }

    awards = Repo.all(Award)
    render(conn, "index.html", awards: awards, employee_info: employee_info)
  end

  def claim(conn, %{"award_id" => award_id}) do
    employee_id = conn.assigns.current_employee.id

    case Rewards.redeem_award(award_id, employee_id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "You have successfuly claimed an award! An email to award.handling@company.com has been sent.")
        |> redirect(to: Routes.award_path(conn, :index))
      {:error, message} ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: Routes.award_path(conn, :index))
    end
  end
end
