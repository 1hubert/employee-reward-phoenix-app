defmodule EmployeeReward.Repo.Migrations.CreatePointsBalances do
  use Ecto.Migration

  def change do
    create table(:points_balances) do
      add :points_to_grant, :integer, default: 0
      add :points_obtained, :integer, default: 0
      add :employee_id, references(:employees, on_delete: :delete_all)

      timestamps()
    end

    create index(:points_balances, [:employee_id])
  end
end
