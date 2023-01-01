defmodule EmployeeReward.AccountsTest do
  use EmployeeReward.DataCase

  alias EmployeeReward.Accounts

  import EmployeeReward.AccountsFixtures
  alias EmployeeReward.Accounts.{Employee, EmployeeToken}

  describe "get_employee_by_email/1" do
    test "does not return the employee if the email does not exist" do
      refute Accounts.get_employee_by_email("unknown@example.com")
    end

    test "returns the employee if the email exists" do
      %{id: id} = employee = employee_fixture()
      assert %Employee{id: ^id} = Accounts.get_employee_by_email(employee.email)
    end
  end

  describe "get_employee_by_email_and_password/2" do
    test "does not return the employee if the email does not exist" do
      refute Accounts.get_employee_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the employee if the password is not valid" do
      employee = employee_fixture()
      refute Accounts.get_employee_by_email_and_password(employee.email, "invalid")
    end

    test "returns the employee if the email and password are valid" do
      %{id: id} = employee = employee_fixture()

      assert %Employee{id: ^id} =
               Accounts.get_employee_by_email_and_password(employee.email, valid_employee_password())
    end
  end

  describe "get_employee!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_employee!(-1)
      end
    end

    test "returns the employee with the given id" do
      %{id: id} = employee = employee_fixture()
      assert %Employee{id: ^id} = Accounts.get_employee!(employee.id)
    end
  end

  describe "register_employee/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Accounts.register_employee(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Accounts.register_employee(%{email: "not valid", password: "bad"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 5 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.register_employee(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 30 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = employee_fixture()
      {:error, changeset} = Accounts.register_employee(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Accounts.register_employee(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers employees with a hashed password" do
      email = unique_employee_email()
      {:ok, employee} = Accounts.register_employee(valid_employee_attributes(email: email))
      assert employee.email == email
      assert is_binary(employee.hashed_password)
      assert is_nil(employee.confirmed_at)
      assert is_nil(employee.password)
    end
  end

  describe "change_employee_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_employee_registration(%Employee{})
      assert changeset.required == [:name, :surname, :password, :email]
    end

    test "allows fields to be set" do
      email = unique_employee_email()
      password = valid_employee_password()

      changeset =
        Accounts.change_employee_registration(
          %Employee{},
          valid_employee_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_employee_email/2" do
    test "returns a employee changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_employee_email(%Employee{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_employee_email/3" do
    setup do
      %{employee: employee_fixture()}
    end

    test "requires email to change", %{employee: employee} do
      {:error, changeset} = Accounts.apply_employee_email(employee, valid_employee_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{employee: employee} do
      {:error, changeset} =
        Accounts.apply_employee_email(employee, valid_employee_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{employee: employee} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.apply_employee_email(employee, valid_employee_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{employee: employee} do
      %{email: email} = employee_fixture()

      {:error, changeset} =
        Accounts.apply_employee_email(employee, valid_employee_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{employee: employee} do
      {:error, changeset} =
        Accounts.apply_employee_email(employee, "invalid", %{email: unique_employee_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{employee: employee} do
      email = unique_employee_email()
      {:ok, employee} = Accounts.apply_employee_email(employee, valid_employee_password(), %{email: email})
      assert employee.email == email
      assert Accounts.get_employee!(employee.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{employee: employee_fixture()}
    end

    test "sends token through notification", %{employee: employee} do
      token =
        extract_employee_token(fn url ->
          Accounts.deliver_update_email_instructions(employee, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert employee_token = Repo.get_by(EmployeeToken, token: :crypto.hash(:sha256, token))
      assert employee_token.employee_id == employee.id
      assert employee_token.sent_to == employee.email
      assert employee_token.context == "change:current@example.com"
    end
  end

  describe "update_employee_email/2" do
    setup do
      employee = employee_fixture()
      email = unique_employee_email()

      token =
        extract_employee_token(fn url ->
          Accounts.deliver_update_email_instructions(%{employee | email: email}, employee.email, url)
        end)

      %{employee: employee, token: token, email: email}
    end

    test "updates the email with a valid token", %{employee: employee, token: token, email: email} do
      assert Accounts.update_employee_email(employee, token) == :ok
      changed_employee = Repo.get!(Employee, employee.id)
      assert changed_employee.email != employee.email
      assert changed_employee.email == email
      assert changed_employee.confirmed_at
      assert changed_employee.confirmed_at != employee.confirmed_at
      refute Repo.get_by(EmployeeToken, employee_id: employee.id)
    end

    test "does not update email with invalid token", %{employee: employee} do
      assert Accounts.update_employee_email(employee, "oops") == :error
      assert Repo.get!(Employee, employee.id).email == employee.email
      assert Repo.get_by(EmployeeToken, employee_id: employee.id)
    end

    test "does not update email if employee email changed", %{employee: employee, token: token} do
      assert Accounts.update_employee_email(%{employee | email: "current@example.com"}, token) == :error
      assert Repo.get!(Employee, employee.id).email == employee.email
      assert Repo.get_by(EmployeeToken, employee_id: employee.id)
    end

    test "does not update email if token expired", %{employee: employee, token: token} do
      {1, nil} = Repo.update_all(EmployeeToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Accounts.update_employee_email(employee, token) == :error
      assert Repo.get!(Employee, employee.id).email == employee.email
      assert Repo.get_by(EmployeeToken, employee_id: employee.id)
    end
  end

  describe "change_employee_password/2" do
    test "returns a employee changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_employee_password(%Employee{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Accounts.change_employee_password(%Employee{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_employee_password/3" do
    setup do
      %{employee: employee_fixture()}
    end

    test "validates password", %{employee: employee} do
      {:error, changeset} =
        Accounts.update_employee_password(employee, valid_employee_password(), %{
          password: "bad",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 5 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{employee: employee} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Accounts.update_employee_password(employee, valid_employee_password(), %{password: too_long})

      assert "should be at most 30 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{employee: employee} do
      {:error, changeset} =
        Accounts.update_employee_password(employee, "invalid", %{password: valid_employee_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{employee: employee} do
      {:ok, employee} =
        Accounts.update_employee_password(employee, valid_employee_password(), %{
          password: "new valid password"
        })

      assert is_nil(employee.password)
      assert Accounts.get_employee_by_email_and_password(employee.email, "new valid password")
    end

    test "deletes all tokens for the given employee", %{employee: employee} do
      _ = Accounts.generate_employee_session_token(employee)

      {:ok, _} =
        Accounts.update_employee_password(employee, valid_employee_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(EmployeeToken, employee_id: employee.id)
    end
  end

  describe "generate_employee_session_token/1" do
    setup do
      %{employee: employee_fixture()}
    end

    test "generates a token", %{employee: employee} do
      token = Accounts.generate_employee_session_token(employee)
      assert employee_token = Repo.get_by(EmployeeToken, token: token)
      assert employee_token.context == "session"

      # Creating the same token for another employee should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%EmployeeToken{
          token: employee_token.token,
          employee_id: employee_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_employee_by_session_token/1" do
    setup do
      employee = employee_fixture()
      token = Accounts.generate_employee_session_token(employee)
      %{employee: employee, token: token}
    end

    test "returns employee by token", %{employee: employee, token: token} do
      assert session_employee = Accounts.get_employee_by_session_token(token)
      assert session_employee.id == employee.id
    end

    test "does not return employee for invalid token" do
      refute Accounts.get_employee_by_session_token("oops")
    end

    test "does not return employee for expired token", %{token: token} do
      {1, nil} = Repo.update_all(EmployeeToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_employee_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      employee = employee_fixture()
      token = Accounts.generate_employee_session_token(employee)
      assert Accounts.delete_session_token(token) == :ok
      refute Accounts.get_employee_by_session_token(token)
    end
  end

  describe "deliver_employee_reset_password_instructions/2" do
    setup do
      %{employee: employee_fixture()}
    end

    test "sends token through notification", %{employee: employee} do
      token =
        extract_employee_token(fn url ->
          Accounts.deliver_employee_reset_password_instructions(employee, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert employee_token = Repo.get_by(EmployeeToken, token: :crypto.hash(:sha256, token))
      assert employee_token.employee_id == employee.id
      assert employee_token.sent_to == employee.email
      assert employee_token.context == "reset_password"
    end
  end

  describe "get_employee_by_reset_password_token/1" do
    setup do
      employee = employee_fixture()

      token =
        extract_employee_token(fn url ->
          Accounts.deliver_employee_reset_password_instructions(employee, url)
        end)

      %{employee: employee, token: token}
    end

    test "returns the employee with valid token", %{employee: %{id: id}, token: token} do
      assert %Employee{id: ^id} = Accounts.get_employee_by_reset_password_token(token)
      assert Repo.get_by(EmployeeToken, employee_id: id)
    end

    test "does not return the employee with invalid token", %{employee: employee} do
      refute Accounts.get_employee_by_reset_password_token("oops")
      assert Repo.get_by(EmployeeToken, employee_id: employee.id)
    end

    test "does not return the employee if token expired", %{employee: employee, token: token} do
      {1, nil} = Repo.update_all(EmployeeToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Accounts.get_employee_by_reset_password_token(token)
      assert Repo.get_by(EmployeeToken, employee_id: employee.id)
    end
  end

  describe "reset_employee_password/2" do
    setup do
      %{employee: employee_fixture()}
    end

    test "validates password", %{employee: employee} do
      {:error, changeset} =
        Accounts.reset_employee_password(employee, %{
          password: "bad",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 5 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{employee: employee} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Accounts.reset_employee_password(employee, %{password: too_long})
      assert "should be at most 30 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{employee: employee} do
      {:ok, updated_employee} = Accounts.reset_employee_password(employee, %{password: "new valid password"})
      assert is_nil(updated_employee.password)
      assert Accounts.get_employee_by_email_and_password(employee.email, "new valid password")
    end

    test "deletes all tokens for the given employee", %{employee: employee} do
      _ = Accounts.generate_employee_session_token(employee)
      {:ok, _} = Accounts.reset_employee_password(employee, %{password: "new valid password"})
      refute Repo.get_by(EmployeeToken, employee_id: employee.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Employee{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
