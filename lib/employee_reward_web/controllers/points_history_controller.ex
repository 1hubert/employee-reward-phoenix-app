defmodule EmployeeRewardWeb.PointsHistoryController do
  use EmployeeRewardWeb, :controller

  alias EmployeeReward.Rewards

  def index(conn, _params) do
    points_history = Rewards.list_points_history()
    render(conn, "index.html", points_history: points_history)
  end
end
