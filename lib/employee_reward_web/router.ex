defmodule EmployeeRewardWeb.Router do
  use EmployeeRewardWeb, :router

  import EmployeeRewardWeb.EmployeeAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {EmployeeRewardWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_employee
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EmployeeRewardWeb do
    pipe_through [:browser, :require_authenticated_employee]

    get "/", EmployeeController, :index
    get "/show/:id", EmployeeController, :show
    post "/grant/:to_id", PointsBalanceController, :grant
    get "/history", PointsHistoryController, :index

    # get "/edit/:id", EmployeeController, :edit
    # patch "/employees/:id", EmployeeController, :update
    # put "/employees/:id", EmployeeController, :update
    # delete "/employees/:id", EmployeeController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", EmployeeRewardWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: EmployeeRewardWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", EmployeeRewardWeb do
    pipe_through [:browser, :redirect_if_employee_is_authenticated]

    get "/employees/register", EmployeeRegistrationController, :new
    post "/employees/register", EmployeeRegistrationController, :create
    get "/employees/log_in", EmployeeSessionController, :new
    post "/employees/log_in", EmployeeSessionController, :create
    get "/employees/reset_password", EmployeeResetPasswordController, :new
    post "/employees/reset_password", EmployeeResetPasswordController, :create
    get "/employees/reset_password/:token", EmployeeResetPasswordController, :edit
    put "/employees/reset_password/:token", EmployeeResetPasswordController, :update
  end

  scope "/", EmployeeRewardWeb do
    pipe_through [:browser, :require_authenticated_employee]

    get "/employees/settings", EmployeeSettingsController, :edit
    put "/employees/settings", EmployeeSettingsController, :update
    get "/employees/settings/confirm_email/:token", EmployeeSettingsController, :confirm_email
  end

  scope "/", EmployeeRewardWeb do
    pipe_through [:browser]

    delete "/employees/log_out", EmployeeSessionController, :delete
    get "/employees/confirm", EmployeeConfirmationController, :new
    post "/employees/confirm", EmployeeConfirmationController, :create
    get "/employees/confirm/:token", EmployeeConfirmationController, :edit
    post "/employees/confirm/:token", EmployeeConfirmationController, :update
  end
end
