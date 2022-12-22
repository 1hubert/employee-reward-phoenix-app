defmodule EmployeeReward.Roles.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :email, :string
    field :name, :string
    field :password, :string
    field :points_obtained, :integer
    field :points_to_grant, :integer
    field :surname, :string

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:email, :name, :surname, :points_to_grant, :points_obtained, :password])
    |> validate_required([:email, :name, :surname, :points_to_grant, :points_obtained, :password])
  end
end
