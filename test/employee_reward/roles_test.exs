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
      valid_attrs = %{email: "some email", name: "some name", password: "some password", points_obtained: 42, points_to_grant: 42, surname: "some surname"}

      assert {:ok, %Employee{} = employee} = Roles.create_employee(valid_attrs)
      assert employee.email == "some email"
      assert employee.name == "some name"
      assert employee.password == "some password"
      assert employee.points_obtained == 42
      assert employee.points_to_grant == 42
      assert employee.surname == "some surname"
    end

    test "create_employee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Roles.create_employee(@invalid_attrs)
    end

    test "update_employee/2 with valid data updates the employee" do
      employee = employee_fixture()
      update_attrs = %{email: "some updated email", name: "some updated name", password: "some updated password", points_obtained: 43, points_to_grant: 43, surname: "some updated surname"}

      assert {:ok, %Employee{} = employee} = Roles.update_employee(employee, update_attrs)
      assert employee.email == "some updated email"
      assert employee.name == "some updated name"
      assert employee.password == "some updated password"
      assert employee.points_obtained == 43
      assert employee.points_to_grant == 43
      assert employee.surname == "some updated surname"
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
