defmodule EmployeeReward.Rewards do
  @moduledoc """
  The Rewards context.
  """

  import Ecto.Query, warn: false
  alias EmployeeReward.Repo

  alias EmployeeReward.Rewards.PointsBalance

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
end
