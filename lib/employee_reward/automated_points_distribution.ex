defmodule EmployeeReward.AutomatedPointsDistribution do
  use GenServer

  alias EmployeeReward.Rewards

  # Client API
  def start_link(_args) do
    GenServer.start_link(__MODULE__, [])
  end

  # Server callbacks
  def init(_) do
    # :timer.send_interval(1000, :test_genserver)
    :timer.send_interval(milliseconds_until_next_month(), :monthly_distribution)
    {:ok, :running}
  end

  def handle_info(:test_genserver, state) do
    IO.puts("Hello from GenServer!")
    {:noreply, state}
  end

  def handle_info(:monthly_distribution, state) do
    Rewards.set_points_to_grant_to_50_for_everyone()
    {:noreply, state}
  end

  # Private functions
  def milliseconds_until_next_month do
    now = DateTime.utc_now()

    first_day_of_next_month =
      if now.month == 12 do
        %DateTime{year: now.year + 1,
                  month: 1,
                  day: 1,
                  zone_abbr: now.zone_abbr,
                  hour: 0,
                  minute: 0,
                  second: 0,
                  utc_offset: now.utc_offset,
                  std_offset: now.std_offset,
                  time_zone: now.time_zone}
      else
        %DateTime{year: now.year,
                  month: now.month + 1,
                  day: 1,
                  zone_abbr: now.zone_abbr,
                  hour: 0,
                  minute: 0,
                  second: 0,
                  utc_offset: now.utc_offset,
                  std_offset: now.std_offset,
                  time_zone: now.time_zone}
      end
      # IO.puts("Days until next month: ")
      # IO.puts(DateTime.diff(first_day_of_next_month, now, :millisecond) / 1000 / 60 / 60 / 24)
      DateTime.diff(first_day_of_next_month, now, :millisecond)
  end
end
