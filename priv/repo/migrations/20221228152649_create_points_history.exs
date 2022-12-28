defmodule EmployeeReward.Repo.Migrations.CreatePointsHistory do
  use Ecto.Migration

  def change do
    create table(:points_history) do
      add :sender, :string
      add :receiver, :string
      add :value, :integer
      add :transaction_type, :string

      timestamps()
    end
  end
end
