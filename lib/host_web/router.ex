defmodule HostWeb.Router do
  use HostWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HostWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HostWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/containers", ContainerLive.Index, :index
    live "/containers/new", ContainerLive.Index, :new
    live "/containers/:id/edit", ContainerLive.Index, :edit

    live "/containers/:id", ContainerLive.Show, :show
    live "/containers/:id/terminal", ContainerLive.TerminalWindow, :show
    live "/containers/:id/logs", ContainerLive.LogsWindow, :show
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
end
