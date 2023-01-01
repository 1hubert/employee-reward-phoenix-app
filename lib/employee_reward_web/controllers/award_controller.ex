defmodule EmployeeRewardWeb.AwardController do
  use EmployeeRewardWeb, :controller

  import EmployeeRewardWeb.AdminAuth

  alias EmployeeReward.{Repo, Rewards}
  alias EmployeeReward.Rewards.Award
  alias EmployeeReward.Accounts.Employee

  plug :require_authenticated_admin when action in [:edit, :update, :delete]

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

  def edit(conn, %{"id" => id}) do
    award = Rewards.get_award!(id)
    changeset = Rewards.change_award(award)
    render(conn, "edit.html", award: award, changeset: changeset)
  end

  def update(conn, %{"id" => id, "award" => award_params}) do
    award = Rewards.get_award!(id)

    case Rewards.update_award(award, award_params) do
      {:ok, _award} ->
        conn
        |> put_flash(:info, "Award updated successfully.")
        |> redirect(to: Routes.admin_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", award: award, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    award = Rewards.get_award!(id)
    {:ok, _award} = Rewards.delete_award(award)

    conn
    |> put_flash(:info, "Award deleted successfully.")
    |> redirect(to: Routes.admin_path(conn, :index))
  end

  def new(conn, _params) do
    changeset = Rewards.change_award(%Award{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"award" => award_params}) do
    case Rewards.create_award(award_params) do
      {:ok, _award} ->
        conn
        |> put_flash(:info, "Award created successfully.")
        |> redirect(to: Routes.admin_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
