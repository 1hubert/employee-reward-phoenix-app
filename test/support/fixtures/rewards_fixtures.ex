defmodule EmployeeReward.RewardsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmployeeReward.Rewards` context.
  """

  @doc """
  Generate a points_balance.
  """
  def points_balance_fixture(attrs \\ %{}) do
    {:ok, points_balance} =
      attrs
      |> Enum.into(%{
        points_obtained: 42,
        points_to_grant: 42
      })
      |> EmployeeReward.Rewards.create_points_balance()

    points_balance
  end

  @doc """
  Generate a points_history.
  """
  def points_history_fixture(attrs \\ %{}) do
    {:ok, points_history} =
      attrs
      |> Enum.into(%{
        receiver: "some receiver",
        sender: "some sender",
        transaction_type: "some transaction_type",
        value: 42
      })
      |> EmployeeReward.Rewards.create_points_history()

    points_history
  end
end
