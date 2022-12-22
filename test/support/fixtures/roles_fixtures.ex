defmodule EmployeeReward.RolesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EmployeeReward.Roles` context.
  """

  @doc """
  Generate a employee.
  """
  def employee_fixture(attrs \\ %{}) do
    {:ok, employee} =
      attrs
      |> Enum.into(%{
        email: "some email",
        name: "some name",
        password: "some password",
        points_obtained: 42,
        points_to_grant: 42,
        surname: "some surname"
      })
      |> EmployeeReward.Roles.create_employee()

    employee
  end
end
