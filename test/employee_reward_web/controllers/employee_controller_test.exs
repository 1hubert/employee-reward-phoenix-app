defmodule EmployeeRewardWeb.EmployeeControllerTest do
  use EmployeeRewardWeb.ConnCase

  import EmployeeReward.AccountsFixtures
  import EmployeeRewardWeb.ConnCase

  @create_attrs %{email: "example@gmail.com", name: "John", surname: "Smith", password: "12345"}
  @update_attrs %{email: "example@protonmail.com", name: "David", surname: "Brown", password: "password"}
  @invalid_attrs %{email: nil, name: nil, surname: nil, password: nil}

  describe "index" do
    test "redirected to log in when not logged in", %{conn: conn} do
      conn = get(conn, Routes.employee_path(conn, :index))
      assert redirected_to(conn) == Routes.employee_session_path(conn, :new)
    end
  end
end
