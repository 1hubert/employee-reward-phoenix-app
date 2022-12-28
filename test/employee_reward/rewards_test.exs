defmodule EmployeeReward.RewardsTest do
  use EmployeeReward.DataCase

  alias EmployeeReward.Rewards

  describe "points_balances" do
    alias EmployeeReward.Rewards.PointsBalance

    import EmployeeReward.RewardsFixtures

    @invalid_attrs %{points_obtained: nil, points_to_grant: nil}

    test "list_points_balances/0 returns all points_balances" do
      points_balance = points_balance_fixture()
      assert Rewards.list_points_balances() == [points_balance]
    end

    test "get_points_balance!/1 returns the points_balance with given id" do
      points_balance = points_balance_fixture()
      assert Rewards.get_points_balance!(points_balance.id) == points_balance
    end

    test "create_points_balance/1 with valid data creates a points_balance" do
      valid_attrs = %{points_obtained: 42, points_to_grant: 42}

      assert {:ok, %PointsBalance{} = points_balance} = Rewards.create_points_balance(valid_attrs)
      assert points_balance.points_obtained == 42
      assert points_balance.points_to_grant == 42
    end

    test "create_points_balance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rewards.create_points_balance(@invalid_attrs)
    end

    test "update_points_balance/2 with valid data updates the points_balance" do
      points_balance = points_balance_fixture()
      update_attrs = %{points_obtained: 43, points_to_grant: 43}

      assert {:ok, %PointsBalance{} = points_balance} = Rewards.update_points_balance(points_balance, update_attrs)
      assert points_balance.points_obtained == 43
      assert points_balance.points_to_grant == 43
    end

    test "update_points_balance/2 with invalid data returns error changeset" do
      points_balance = points_balance_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_points_balance(points_balance, @invalid_attrs)
      assert points_balance == Rewards.get_points_balance!(points_balance.id)
    end

    test "delete_points_balance/1 deletes the points_balance" do
      points_balance = points_balance_fixture()
      assert {:ok, %PointsBalance{}} = Rewards.delete_points_balance(points_balance)
      assert_raise Ecto.NoResultsError, fn -> Rewards.get_points_balance!(points_balance.id) end
    end

    test "change_points_balance/1 returns a points_balance changeset" do
      points_balance = points_balance_fixture()
      assert %Ecto.Changeset{} = Rewards.change_points_balance(points_balance)
    end
  end

  describe "points_history" do
    alias EmployeeReward.Rewards.PointsHistory

    import EmployeeReward.RewardsFixtures

    @invalid_attrs %{receiver: nil, sender: nil, transaction_type: nil, value: nil}

    test "list_points_history/0 returns all points_history" do
      points_history = points_history_fixture()
      assert Rewards.list_points_history() == [points_history]
    end

    test "get_points_history!/1 returns the points_history with given id" do
      points_history = points_history_fixture()
      assert Rewards.get_points_history!(points_history.id) == points_history
    end

    test "create_points_history/1 with valid data creates a points_history" do
      valid_attrs = %{receiver: "some receiver", sender: "some sender", transaction_type: "some transaction_type", value: 42}

      assert {:ok, %PointsHistory{} = points_history} = Rewards.create_points_history(valid_attrs)
      assert points_history.receiver == "some receiver"
      assert points_history.sender == "some sender"
      assert points_history.transaction_type == "some transaction_type"
      assert points_history.value == 42
    end

    test "create_points_history/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Rewards.create_points_history(@invalid_attrs)
    end

    test "update_points_history/2 with valid data updates the points_history" do
      points_history = points_history_fixture()
      update_attrs = %{receiver: "some updated receiver", sender: "some updated sender", transaction_type: "some updated transaction_type", value: 43}

      assert {:ok, %PointsHistory{} = points_history} = Rewards.update_points_history(points_history, update_attrs)
      assert points_history.receiver == "some updated receiver"
      assert points_history.sender == "some updated sender"
      assert points_history.transaction_type == "some updated transaction_type"
      assert points_history.value == 43
    end

    test "update_points_history/2 with invalid data returns error changeset" do
      points_history = points_history_fixture()
      assert {:error, %Ecto.Changeset{}} = Rewards.update_points_history(points_history, @invalid_attrs)
      assert points_history == Rewards.get_points_history!(points_history.id)
    end

    test "delete_points_history/1 deletes the points_history" do
      points_history = points_history_fixture()
      assert {:ok, %PointsHistory{}} = Rewards.delete_points_history(points_history)
      assert_raise Ecto.NoResultsError, fn -> Rewards.get_points_history!(points_history.id) end
    end

    test "change_points_history/1 returns a points_history changeset" do
      points_history = points_history_fixture()
      assert %Ecto.Changeset{} = Rewards.change_points_history(points_history)
    end
  end
end
