defmodule EmployeeReward.Rewards do
  @moduledoc """
  The Rewards context.
  """

  import Ecto.Query, warn: false

  alias EmployeeReward.Accounts.{EmployeeNotifier, Employee}
  alias Ecto.Multi
  alias EmployeeReward.Repo
  alias EmployeeReward.Rewards.{PointsBalance, PointsHistory, Award}

  @doc """
  Returns the list of points_balances.

  ## Examples

      iex> list_points_balances()
      [%PointsBalance{}, ...]

  """
  def list_points_balances do
    Repo.all(PointsBalance)
  end

  @doc """
  Gets a single points_balance.

  Raises `Ecto.NoResultsError` if the Points balance does not exist.

  ## Examples

      iex> get_points_balance!(123)
      %PointsBalance{}

      iex> get_points_balance!(456)
      ** (Ecto.NoResultsError)

  """
  def get_points_balance!(id), do: Repo.get!(PointsBalance, id)

  @doc """
  Creates a points_balance.

  ## Examples

      iex> create_points_balance(%{field: value})
      {:ok, %PointsBalance{}}

      iex> create_points_balance(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_points_balance(attrs \\ %{}) do
    %PointsBalance{}
    |> PointsBalance.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a points_balance.

  ## Examples

      iex> update_points_balance(points_balance, %{field: new_value})
      {:ok, %PointsBalance{}}

      iex> update_points_balance(points_balance, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_points_balance(%PointsBalance{} = points_balance, attrs) do
    points_balance
    |> PointsBalance.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a points_balance.

  ## Examples

      iex> delete_points_balance(points_balance)
      {:ok, %PointsBalance{}}

      iex> delete_points_balance(points_balance)
      {:error, %Ecto.Changeset{}}

  """
  def delete_points_balance(%PointsBalance{} = points_balance) do
    Repo.delete(points_balance)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking points_balance changes.

  ## Examples

      iex> change_points_balance(points_balance)
      %Ecto.Changeset{data: %PointsBalance{}}

  """
  def change_points_balance(%PointsBalance{} = points_balance, attrs \\ %{}) do
    PointsBalance.changeset(points_balance, attrs)
  end

  def set_points_to_grant_to_50_for_everyone() do
    Repo.update_all(PointsBalance, set: [points_to_grant: 50])
  end

  def grant_points(_from_id, _to_id, amount) when amount < 1 do
    {:error, "You cannot gift less than 1 point"}
  end

  def grant_points(from_id, to_id, _amount) when from_id == to_id do
    {:error, "You cannot gift points to yourself!"}
  end

  def grant_points(from_id, to_id, amount) when from_id != to_id do
    sender_balance = Repo.get_by!(PointsBalance, [employee_id: from_id])
    receiver_balance = Repo.get_by!(PointsBalance, [employee_id: to_id])

    %{points_to_grant: old_points_to_grant} = sender_balance
    %{points_obtained: old_obtained_points} = receiver_balance

    case old_points_to_grant >= amount do
      true ->
        new_points_to_grant = old_points_to_grant - amount
        new_obtained_points = old_obtained_points + amount

        sender_email =
          sender_balance
          |> Repo.preload(:employee)
          |> Map.get(:employee)
          |> Map.get(:email)

        receiver_email =
          receiver_balance
          |> Repo.preload(:employee)
          |> Map.get(:employee)
          |> Map.get(:email)

        Multi.new()
        |> Multi.update(:substract_points_to_grant, change_points_balance(sender_balance, %{points_to_grant: new_points_to_grant}))
        |> Multi.update(:add_obtained_points, change_points_balance(receiver_balance, %{points_obtained: new_obtained_points}))
        |> Multi.insert(:record_transaction_in_history, PointsHistory.changeset(%PointsHistory{}, %{receiver: receiver_email, sender: sender_email, transaction_type: "Grant points", value: amount}))
        |> Repo.transaction()
      false ->
        {:error, "Not enough points available"}
    end
  end

  @doc """
  Returns the list of points_history.

  ## Examples

      iex> list_points_history()
      [%PointsHistory{}, ...]

  """
  def list_points_history do
    Repo.all(from p in PointsHistory, order_by: [desc: p.id])
  end

  def list_recently_given_rewards(employee_id) do
    sender_email =
      Repo.get!(Employee, employee_id)
      |> Map.get(:email)

    query = from p in PointsHistory,
      where: p.transaction_type == "Grant points" and p.sender == ^sender_email,
      select: %{
        id: p.id,
        value: p.value,
        receiver: p.receiver,
        inserted_at: p.inserted_at
      },
      order_by: [desc: p.id]

    Repo.all(query)
  end

  @doc """
  Gets a single points_history.

  Raises `Ecto.NoResultsError` if the Points history does not exist.

  ## Examples

      iex> get_points_history!(123)
      %PointsHistory{}

      iex> get_points_history!(456)
      ** (Ecto.NoResultsError)

  """
  def get_points_history!(id), do: Repo.get!(PointsHistory, id)

  @doc """
  Creates a points_history.

  ## Examples

      iex> create_points_history(%{field: value})
      {:ok, %PointsHistory{}}

      iex> create_points_history(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_points_history(attrs \\ %{}) do
    %PointsHistory{}
    |> PointsHistory.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a points_history.

  ## Examples

      iex> update_points_history(points_history, %{field: new_value})
      {:ok, %PointsHistory{}}

      iex> update_points_history(points_history, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_points_history(%PointsHistory{} = points_history, attrs) do
    points_history
    |> PointsHistory.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a points_history.

  ## Examples

      iex> delete_points_history(points_history)
      {:ok, %PointsHistory{}}

      iex> delete_points_history(points_history)
      {:error, %Ecto.Changeset{}}

  """
  def delete_points_history(%PointsHistory{} = points_history) do
    Repo.delete(points_history)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking points_history changes.

  ## Examples

      iex> change_points_history(points_history)
      %Ecto.Changeset{data: %PointsHistory{}}

  """
  def change_points_history(%PointsHistory{} = points_history, attrs \\ %{}) do
    PointsHistory.changeset(points_history, attrs)
  end

  @doc """
  Returns the list of awards.

  ## Examples

      iex> list_awards()
      [%Award{}, ...]

  """
  def list_awards do
    Repo.all(Award)
  end

  @doc """
  Gets a single award.

  Raises `Ecto.NoResultsError` if the Award does not exist.

  ## Examples

      iex> get_award!(123)
      %Award{}

      iex> get_award!(456)
      ** (Ecto.NoResultsError)

  """
  def get_award!(id), do: Repo.get!(Award, id)

  @doc """
  Creates a award.

  ## Examples

      iex> create_award(%{field: value})
      {:ok, %Award{}}

      iex> create_award(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_award(attrs \\ %{}) do
    %Award{}
    |> Award.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a award.

  ## Examples

      iex> update_award(award, %{field: new_value})
      {:ok, %Award{}}

      iex> update_award(award, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_award(%Award{} = award, attrs) do
    award
    |> Award.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a award.

  ## Examples

      iex> delete_award(award)
      {:ok, %Award{}}

      iex> delete_award(award)
      {:error, %Ecto.Changeset{}}

  """
  def delete_award(%Award{} = award) do
    Repo.delete(award)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking award changes.

  ## Examples

      iex> change_award(award)
      %Ecto.Changeset{data: %Award{}}

  """
  def change_award(%Award{} = award, attrs \\ %{}) do
    Award.changeset(award, attrs)
  end

  def redeem_award(award_id, employee_id) do
    # update employee balance (obtained_points-award_cost)
    # update employee history (value=award_cost, action="Redeem award")
    # maybe send an email to employee + some person managing this system like awards@company.com

    employee_balance = Repo.get_by!(PointsBalance, [employee_id: employee_id])
    award = Repo.get_by!(Award, [id: award_id])

    %{points_obtained: old_points_obtained} = employee_balance
    %{point_cost: award_cost} = award

    case old_points_obtained >= award_cost do
      true ->
        new_points_obtained = old_points_obtained - award_cost

        employee_email =
          employee_balance
          |> Repo.preload(:employee)
          |> Map.get(:employee)
          |> Map.get(:email)

        staff_email = "award.handling@company.com"
        employee = Repo.get!(Employee, employee_id)

        EmployeeNotifier.deliver_award_claimed_notification(staff_email, award, employee)

        Multi.new()
        |> Multi.update(:substract_points_obtained, change_points_balance(employee_balance, %{points_obtained: new_points_obtained}))
        |> Multi.insert(:record_transaction_in_history, PointsHistory.changeset(%PointsHistory{}, %{receiver: staff_email, sender: employee_email, transaction_type: "Redeem award", value: award_cost}))
        |> Repo.transaction()
      false ->
        {:error, "Not enough points available"}
    end
  end
end
