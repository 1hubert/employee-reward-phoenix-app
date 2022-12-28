defmodule EmployeeReward.Rewards do
  @moduledoc """
  The Rewards context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias EmployeeReward.Repo
  alias EmployeeReward.Rewards.{PointsBalance, PointsHistory}

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
end
