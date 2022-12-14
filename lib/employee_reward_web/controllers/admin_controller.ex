defmodule EmployeeRewardWeb.AdminController do
  use EmployeeRewardWeb, :controller

  import Ecto.Query, only: [from: 2]
  import EmployeeRewardWeb.AdminAuth

  alias EmployeeReward.Rewards.PointsHistory
  alias EmployeeReward.{Repo, Rewards}

  plug :require_authenticated_admin

  def index(conn, _params) do
    awards = Rewards.list_awards()
    points_balances =
      Rewards.list_points_balances()
      |> Repo.preload(:employee)

    query = from p in PointsHistory,
      where: p.transaction_type == "Grant points",
      select: fragment("distinct on (?) ?", fragment("date_trunc('month', ?)", p.inserted_at), fragment("date_trunc('month', ?)", p.inserted_at)),
      order_by: fragment("date_trunc('month', ?)", p.inserted_at)

    distinct_year_months =
      Repo.all(query)
      |> Enum.map(fn x -> {"#{x.year}-#{x.month}", "#{x.year}-#{x.month}"} end)


    render(conn, "index.html", awards: awards, points_balances: points_balances, distinct_year_months: distinct_year_months)
  end

  def report(conn, %{"year_month" => year_month}) do
    if year_month == "" do
      conn
      |> put_flash(:error, "Please select year and month")
      |> redirect(to: Routes.admin_path(conn, :index))
    else
      <<year::bytes-size(4)>> <> "-" <> month = year_month

      {year, _} = Float.parse(year)
      {month, _} = Float.parse(month)

      query = from p in PointsHistory,
        where: p.transaction_type == "Grant points",
        select: %{
          {fragment("date_part('year', ?)", p.inserted_at), fragment("date_part('month', ?)", p.inserted_at)} => %{email: p.receiver , total_points: sum(p.value)}
        },
        order_by: [fragment("date_part('year', ?)", p.inserted_at), fragment("date_part('month', ?)", p.inserted_at)],
        group_by: [fragment("date_part('year', ?)", p.inserted_at), fragment("date_part('month', ?)", p.inserted_at), p.receiver]

      employee_points =
        Repo.all(query)
        |> group_values_by_year_month()
        |> Map.get({year, month})

      case employee_points == nil do
        true ->
          conn
          |> put_flash(:error, "No records from #{trunc(year)} #{convert_month(month)}")
          |> redirect(to: Routes.admin_path(conn, :index))
        false ->
          render(conn, "report.html", employee_points: employee_points, year: trunc(year), month: convert_month(month))
      end
    end
  end

#   ----------
#   Group values in a list of maps by unique keys.
#
#   ## Example
#   iex> list = [
#                %{{2022.0, 9.0} => %{email: "hrozmarynowski776@gmail.com", total_points: 23}},
#                %{{2022.0, 9.0} => %{email: "marek@gmail.com", total_points: 22}},
#                %{{2022.0, 10.0} => %{email: "john@gmail.com", total_points: 19}},
#                %{{2022.0, 10.0} => %{email: "michael@gmail.com", total_points: 21}},
#                %{{2022.0, 11.0} => %{email: "hrozmarynowski776@gmail.com", total_points: 20}},
#                %{{2022.0, 11.0} => %{email: "john@gmail.com", total_points: 20}},
#                %{{2022.0, 11.0} => %{email: "marek@gmail.com", total_points: 50}},
#                %{{2022.0, 12.0} => %{email: "hrozmarynowski776@gmail.com", total_points: 144}},
#                %{{2022.0, 12.0} => %{email: "john@gmail.com", total_points: 16}},
#                %{{2022.0, 12.0} => %{email: "marek@gmail.com", total_points: 14}},
#                %{{2022.0, 12.0} => %{email: "michael@gmail.com", total_points: 26}}
#              ]
#   iex> group_values_by_year_month(list)
#   %{
#     {2022.0, 9.0} => [
#       %{email: "hrozmarynowski776@gmail.com", total_points: 23},
#       %{email: "marek@gmail.com", total_points: 22}
#     ],
#     {2022.0, 10.0} => [
#       %{email: "john@gmail.com", total_points: 19},
#       %{email: "michael@gmail.com", total_points: 21}
#     ],
#     {2022.0, 11.0} => [
#       %{email: "hrozmarynowski776@gmail.com", total_points: 20},
#       %{email: "john@gmail.com", total_points: 20},
#       %{email: "marek@gmail.com", total_points: 50}
#     ],
#     {2022.0, 12.0} => [
#       %{email: "hrozmarynowski776@gmail.com", total_points: 144},
#       %{email: "john@gmail.com", total_points: 16},
#       %{email: "marek@gmail.com", total_points: 14},
#       %{email: "michael@gmail.com", total_points: 26}
#     ]
#   }
# ----------
  defp group_values_by_year_month(list) do
    result = Enum.reduce(list, %{}, fn x, acc ->
      key = List.first(Map.keys(x))
      value = Map.values(x)
      case key in Map.keys(acc) do
        true ->
          Map.put(acc, key, acc[key] ++ value)
        false ->
            Map.put(acc, key, value)
      end
    end)

    result
  end

  defp convert_month(month) do
    case trunc(month) do
      1 -> "January"
      2 -> "February"
      3 -> "March"
      4 -> "April"
      5 -> "May"
      6 -> "June"
      7 -> "July"
      8 -> "August"
      9 -> "September"
      10 -> "October"
      11 -> "November"
      12 -> "December"
    end
  end
end
