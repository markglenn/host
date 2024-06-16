defmodule HostWeb.Router do
  use HostWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HostWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HostWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/containers", ContainerLive.Index, :index
    live "/containers/:id", ContainerLive.Show, :show
    live "/containers/:id/shell", ContainerLive.Shell, :show
    live "/containers/:id/logs", ContainerLive.Logs, :show

    live "/vms", VirtualMachineLive.Index, :index
    live "/vms/new", VirtualMachineLive.Index, :new
    live "/vms/:id/edit", VirtualMachineLive.Index, :edit
    live "/vms/:id", VirtualMachineLive.Show, :show
    live "/vms/:id/show/edit", VirtualMachineLive.Show, :edit

    get "/files/raw/*path", FileController, :show

    live "/files", FileLive.Index, :index
    live "/files/listing/*path", FileLive.Index, :index
    live "/files/preview/*path", FileLive.Show, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", HostWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:host, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: HostWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Place a token on the conn to authenticate the user over the user socket
  defp put_user_token(%{assigns: assigns} = conn, _) do
    with current_user_id <- get_in(assigns, [:current_user, :id]),
         token <- Phoenix.Token.sign(conn, "user socket", current_user_id) do
      assign(conn, :user_token, token)
    end
  end
end
