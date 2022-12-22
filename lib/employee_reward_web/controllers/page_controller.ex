defmodule EmployeeRewardWeb.PageController do
  use EmployeeRewardWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
