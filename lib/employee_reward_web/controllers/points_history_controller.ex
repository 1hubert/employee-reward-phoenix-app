defmodule EmployeeRewardWeb.PointsHistoryController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Rewards

  def index(conn, _params) do
    points_history = Rewards.list_recently_given_rewards(conn.assigns.current_employee.id)
    render(conn, "index.html", points_history: points_history)
  end
end
