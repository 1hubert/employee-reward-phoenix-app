defmodule EmployeeReward.RolesTest do
  use EmployeeReward.DataCase

  alias EmployeeReward.Roles

  describe "employees" do
    alias EmployeeReward.Roles.Employee

    import EmployeeReward.RolesFixtures

    @invalid_attrs %{email: nil, name: nil, password: nil, points_obtained: nil, points_to_grant: nil, surname: nil}

    test "list_employees/0 returns all employees" do
      employee = employee_fixture()
      assert Roles.list_employees() == [employee]
    end

    test "get_employee!/1 returns the employee with given id" do
      employee = employee_fixture()
      assert Roles.get_employee!(employee.id) == employee
    end

    test "create_employee/1 with valid data creates a employee" do
      valid_attrs = %{email: "example@gmail.com", name: "John", surname: "Smith", points_obtained: 42, points_to_grant: 42, password: "12345"}

      assert {:ok, %Employee{} = employee} = Roles.create_employee(valid_attrs)
      assert employee.email == "example@gmail.com"
      assert employee.name == "John"
      assert employee.surname == "Smith"
      assert employee.points_obtained == 42
      assert employee.points_to_grant == 42
      assert employee.password == "12345"
    end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Roles.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()
      update_attrs = %{email: "example@protonmail.com", name: "David", surname: "Brown", points_obtained: 43, points_to_grant: 43, password: "password"}

      assert {:ok, %Employee{} = employee} = Roles.update_employee(employee, update_attrs)
      assert employee.email == "example@protonmail.com"
      assert employee.name == "David"
      assert employee.surname == "Brown"
      assert employee.points_obtained == 43
      assert employee.points_to_grant == 43
      assert employee.password == "password"
    end

    test "update_employee/2 with invalid data returns error changeset" do
      employee = employee_fixture()
      assert {:error, %Ecto.Changeset{}} = Roles.update_employee(employee, @invalid_attrs)
      assert employee == Roles.get_employee!(employee.id)
    end

    test "delete_employee/1 deletes the employee" do
      employee = employee_fixture()
      assert {:ok, %Employee{}} = Roles.delete_employee(employee)
      assert_raise Ecto.NoResultsError, fn -> Roles.get_employee!(employee.id) end
    end

    test "change_employee/1 returns a employee changeset" do
      employee = employee_fixture()
      assert %Ecto.Changeset{} = Roles.change_employee(employee)
    end
  end
end
