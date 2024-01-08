defmodule BankApiWeb.Router do
  use BankApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :auth do
    plug BankApi.Accounts.Pipeline
  end

  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api", BankApiWeb do
    pipe_through [:api, :auth, :ensure_auth]

    scope "/v1", V1 do
      resources "/users", UserController, only: [:show] do
        get "/balance", UserController, :balance
      end

      resources "/transactions", TransactionController, only: [:create, :show]
      get "/logout", SessionController, :delete
    end
  end

  scope "/api", BankApiWeb do
    pipe_through [:api, :auth]

    scope "/v1", V1 do
      resources "/users", UserController, only: [:create]
      post "/login", SessionController, :create
    end
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:bank_api, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: BankApiWeb.Telemetry
    end
  end
end
