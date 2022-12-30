defmodule EmployeeReward.Rewards.Award do
  use Ecto.Schema
  import Ecto.Changeset

  schema "awards" do
    field :award_name, :string
    field :award_description, :string
    field :point_cost, :integer

    timestamps()
  end

  @doc false
  def changeset(award, attrs) do
    award
    |> cast(attrs, [:award_name, :point_cost, :award_description])
    |> validate_required([:award_name, :point_cost, :award_description])
    |> validate_number(:point_cost, greater_than: 0)
  end
end
