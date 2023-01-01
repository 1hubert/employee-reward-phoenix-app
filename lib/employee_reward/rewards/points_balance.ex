defmodule EmployeeReward.Rewards.PointsBalance do
  use Ecto.Schema
  import Ecto.Changeset

  alias EmployeeReward.Accounts.Employee

  schema "points_balances" do
    field :points_obtained, :integer, default: 0
    field :points_to_grant, :integer, default: 0
    belongs_to :employee, Employee, foreign_key: :employee_id

    timestamps()
  end

  @doc false
  def changeset(points_balance, attrs) do
    points_balance
    |> cast(attrs, [:points_to_grant, :points_obtained, :employee_id])
    |> validate_required([:points_to_grant, :points_obtained, :employee_id])
    |> validate_number(:points_to_grant, greater_than_or_equal_to: 0)
    |> validate_number(:points_obtained, greater_than_or_equal_to: 0)
  end
end
