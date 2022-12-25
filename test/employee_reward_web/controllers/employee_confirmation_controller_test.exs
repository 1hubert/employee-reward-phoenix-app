defmodule EmployeeRewardWeb.EmployeeConfirmationControllerTest do
  use EmployeeRewardWeb.ConnCase, async: true

  alias EmployeeReward.Accounts
  alias EmployeeReward.Repo
  import EmployeeReward.AccountsFixtures

  setup do
    %{employee: employee_fixture()}
  end

  describe "GET /employees/confirm" do
    test "renders the resend confirmation page", %{conn: conn} do
      conn = get(conn, Routes.employee_confirmation_path(conn, :new))
      response = html_response(conn, 200)
      assert response =~ "<h1>Resend confirmation instructions</h1>"
    end
  end

  describe "POST /employees/confirm" do
    @tag :capture_log
    test "sends a new confirmation token", %{conn: conn, employee: employee} do
      conn =
        post(conn, Routes.employee_confirmation_path(conn, :create), %{
          "employee" => %{"email" => employee.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.get_by!(Accounts.EmployeeToken, employee_id: employee.id).context == "confirm"
    end

    test "does not send confirmation token if Employee is confirmed", %{conn: conn, employee: employee} do
      Repo.update!(Accounts.Employee.confirm_changeset(employee))

      conn =
        post(conn, Routes.employee_confirmation_path(conn, :create), %{
          "employee" => %{"email" => employee.email}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      refute Repo.get_by(Accounts.EmployeeToken, employee_id: employee.id)
    end

    test "does not send confirmation token if email is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.employee_confirmation_path(conn, :create), %{
          "employee" => %{"email" => "unknown@example.com"}
        })

      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "If your email is in our system"
      assert Repo.all(Accounts.EmployeeToken) == []
    end
  end

  describe "GET /employees/confirm/:token" do
    test "renders the confirmation page", %{conn: conn} do
      conn = get(conn, Routes.employee_confirmation_path(conn, :edit, "some-token"))
      response = html_response(conn, 200)
      assert response =~ "<h1>Confirm account</h1>"

      form_action = Routes.employee_confirmation_path(conn, :update, "some-token")
      assert response =~ "action=\"#{form_action}\""
    end
  end

  describe "POST /employees/confirm/:token" do
    test "confirms the given token once", %{conn: conn, employee: employee} do
      token =
        extract_employee_token(fn url ->
          Accounts.deliver_employee_confirmation_instructions(employee, url)
        end)

      conn = post(conn, Routes.employee_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :info) =~ "Employee confirmed successfully"
      assert Accounts.get_employee!(employee.id).confirmed_at
      refute get_session(conn, :employee_token)
      assert Repo.all(Accounts.EmployeeToken) == []

      # When not logged in
      conn = post(conn, Routes.employee_confirmation_path(conn, :update, token))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Employee confirmation link is invalid or it has expired"

      # When logged in
      conn =
        build_conn()
        |> log_in_employee(employee)
        |> post(Routes.employee_confirmation_path(conn, :update, token))

      assert redirected_to(conn) == "/"
      refute get_flash(conn, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, employee: employee} do
      conn = post(conn, Routes.employee_confirmation_path(conn, :update, "oops"))
      assert redirected_to(conn) == "/"
      assert get_flash(conn, :error) =~ "Employee confirmation link is invalid or it has expired"
      refute Accounts.get_employee!(employee.id).confirmed_at
    end
  end
end
