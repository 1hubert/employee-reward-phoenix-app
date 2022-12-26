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
end
