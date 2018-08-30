defmodule Discuss.Router do
  use Discuss.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Discuss.Plugs.SetUser
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Discuss do
    pipe_through :browser # Use the default browser stack

    #get "/", TopicController, :index
    #get "/topics/new", TopicController, :new
    #post "/topics", TopicController, :create
    #get "/topics/:id/edit", TopicController, :edit
    #put "/topics/:id", TopicController, :update
    resources "/", TopicController
  end

  scope "/auth", Discuss do 
    pipe_through :browser #Use the default browser stack

    #route that handle the out going requests. 
    #When user comes to this route, ueberauth will intercept it and then send them off to github
    #This is handled by ueberauth
    #we don't have to define request function. It is authomatically handled by plug ueberauth in auth_controller.ex
    get "/signout", AuthController, :signout
    get "/:provider", AuthController, :request
    #when the user comes back from github we will receive the route below with a callback function by authcontroller
    #This is handle by us
    get "/:provider/callback", AuthController, :callback
  end
  
  # Other scopes may use custom stacks.
  # scope "/api", Discuss do
  #   pipe_through :api
  # end
end
