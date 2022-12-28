defmodule EmployeeRewardWeb.PointsHistoryControllerTest do
  use EmployeeRewardWeb.ConnCase

  import EmployeeReward.RewardsFixtures

  @create_attrs %{receiver: "some receiver", sender: "some sender", transaction_type: "some transaction_type", value: 42}
  @update_attrs %{receiver: "some updated receiver", sender: "some updated sender", transaction_type: "some updated transaction_type", value: 43}
  @invalid_attrs %{receiver: nil, sender: nil, transaction_type: nil, value: nil}

  describe "index" do
    test "lists all points_history", %{conn: conn} do
      conn = get(conn, Routes.points_history_path(conn, :index))
      assert html_response(conn, 200) =~ "Points history"
    end
  end
end
