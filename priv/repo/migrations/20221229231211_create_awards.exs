defmodule EmployeeReward.Repo.Migrations.CreateAwards do
  use Ecto.Migration

  def change do
    create table(:awards) do
      add :award_name, :string
      add :award_description, :string
      add :point_cost, :integer

      timestamps()
    end
  end
end
