defmodule EmployeeRewardWeb.EmployeeRegistrationControllerTest do
  use EmployeeRewardWeb.ConnCase, async: true

  import EmployeeReward.AccountsFixtures

  describe "GET /employees/register" do
    test "renders registration page", %{conn: conn} do
      conn = get(conn, Routes.employee_registration_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "Log in"
      assert response =~ "Register"
    end

    test "redirects if already logged in", %{conn: conn} do
      conn = conn |> log_in_employee(employee_fixture()) |> get(Routes.employee_registration_path(conn, :new))
      assert redirected_to(conn) == "/"
    end
  end

  describe "POST /employees/register" do
    @tag :capture_log
    test "creates account and logs the employee in", %{conn: conn} do
      email = unique_employee_email()

      conn =
        post(conn, Routes.employee_registration_path(conn, :create), %{
          "employee" => valid_employee_attributes(email: email)
        })

      assert get_session(conn, :employee_token)
      assert redirected_to(conn) == "/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ email
      assert response =~ "Settings"
      assert response =~ "Log out"
    end

    test "render errors for invalid data", %{conn: conn} do
      conn =
        post(conn, Routes.employee_registration_path(conn, :create), %{
          "employee" => %{"email" => "with spaces", "password" => "bad"}
        })

      response = html_response(conn, 200)
      assert response =~ "<h1>Register</h1>"
      assert response =~ "must have the @ sign and no spaces"
      assert response =~ "should be at least 5 character"
    end
  end
end
