defmodule EmployeeReward.Repo.Migrations.CreateEmployees do
  use Ecto.Migration

  def change do
    create table(:employees) do
      add :email, :string
      add :name, :string
      add :surname, :string
      add :points_to_grant, :integer
      add :points_obtained, :integer
      add :password, :string

      timestamps()
    end
  end
end
