defmodule EmployeeReward.Accounts.EmployeeNotifier do
  import Swoosh.Email

  alias EmployeeReward.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"EmployeeReward", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to reset a employee password.
  """
  def deliver_reset_password_instructions(employee, url) do
    deliver(employee.email, "Reset password instructions", """

    ==============================

    Hi #{employee.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Notify employee that he has received points from a colleague.
  """
  def deliver_received_points_notification(employee, point_value, sender) do
    deliver(employee.email, "Someone granted you points on Employee Reward App", """

    ==============================

    Hi #{employee.name},

    #{sender.name} #{sender.surname} (#{sender.email}) has granted you #{point_value} points!

    ==============================
    """)
  end

  @doc """
  Notify company staff responsible for giving awards that an employee has successfuly claimed an award.
  """
  def deliver_award_claimed_notification(staff_email, award, employee) do
    deliver(staff_email, "An award has been claimed on Employee Reward App", """

    ==============================

    An award with the ID of #{award.id} (#{award.award_name}) has been claimed by #{employee.name} #{employee.surname} (employee ID: #{employee.id}).

    ==============================
    """)
  end
end
