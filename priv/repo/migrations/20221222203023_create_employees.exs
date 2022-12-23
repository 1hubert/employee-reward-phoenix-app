defmodule EmployeeReward.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :email, :string
      add :name, :string
      add :surname, :string
      add :points_to_grant, :integer, default: 0
      add :points_obtained, :integer, default: 0
      add :password, :string

      timestamps()
    end
  end
end
