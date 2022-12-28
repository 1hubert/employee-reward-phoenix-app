defmodule EmployeeReward.Rewards.PointsHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "points_history" do
    field :sender, :string
    field :receiver, :string
    field :value, :integer
    field :transaction_type, :string

    timestamps()
  end

  @doc false
  def changeset(points_history, attrs) do
    points_history
    |> cast(attrs, [:sender, :receiver, :value, :transaction_type])
    |> validate_required([:sender, :receiver, :value, :transaction_type])
    |> validate_inclusion(:transaction_type, ["Monthly points distribution", "Grant points", "Admin edit"])
    |> validate_number(:value, greater_than_or_equal_to: 0)
  end
end
