defmodule EmployeeReward.Repo do
  use Ecto.Repo,
    otp_app: :employee_reward,
    adapter: Ecto.Adapters.Postgres
end
