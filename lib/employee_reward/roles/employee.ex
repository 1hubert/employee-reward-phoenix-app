defmodule EmployeeReward.Roles.Employee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "employees" do
    field :email, :string
    field :name, :string
    field :surname, :string
    field :points_obtained, :integer, default: 0
    field :points_to_grant, :integer, default: 0
    field :password, :string

    timestamps()
  end

  @doc false
  def changeset(employee, attrs) do
    employee
    |> cast(attrs, [:email, :name, :surname, :points_to_grant, :points_obtained, :password])
    |> validate_required([:email, :name, :surname, :password])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, fn email -> String.downcase(email) end)
    |> update_change(:name, fn name -> String.capitalize(name) end)
    |> update_change(:surname, fn surname -> String.capitalize(surname) end)
    |> validate_length(:name, min: 2, max: 30)
    |> validate_length(:surname, min: 2, max: 30)
    |> validate_length(:password, min: 5, max: 30)
    |> validate_number(:points_to_grant, greater_than_or_equal_to: 0, less_than_or_equal_to: 50)
    |> validate_number(:points_obtained, greater_than_or_equal_to: 0)
  end
end
