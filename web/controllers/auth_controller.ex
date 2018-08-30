defmodule Discuss.AuthController do
  #need to tell phoenix to configure this module as a controller
  use Discuss.Web, :controller
  #to tell the controller to very tightly couple with this controller
  plug Ueberauth

  #if we don't alias then, in the changeset,
  #it should be changeset = Discuss.User.changeset()
  alias Discuss.User

  #in this callback any information that comes back from github is handled
  #whenever the user gets to this callback function, conn has a bunch of information about a particular user 
  #This function takes the information of the user and create a record(new changeset) and insert that into our database.
  #this then gives some record of user about the existance and somehow associates the user with the topic he has created
  #def callback(conn, params) do
  #the conn object is a map, it has assigns property which is a map and has ueberauth_auth property

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
   
    # IO.inspect(auth)--the info below can be taken from console after running the server
    #IO.inspect(auth) gives the info, and take the required info accordingly
    #below is all the information that we want to insert in the database
    #first we make a changeset, then we pass that changeset to repo.insert. and repo.insert will put the info to the database
    user_params = %{token: auth.credentials.token, email: auth.info.email, provider: "github"}
    #from the changeset in user model, we should pass empty user struct and, user params
    #
    changeset = User.changeset(%User{}, user_params)
    signin(conn, changeset)
  end

  #take the id of the user who has been saved into the database
  #and stash it in the user session
  #
  defp signin(conn, changeset) do 
    case insert_or_update_user(changeset) do 
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> put_session(:user_id, user.id)  
        |> redirect(to: topic_path(conn, :index))        
      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error signing in")
        |> redirect(to: topic_path(conn, :index))
    end
  end

  #handler for handling signout function
  def signout(conn, _params)do
    #any function or any data tied to the current user, drop all of it
    conn
    |> configure_session(drop: true)
    |> redirect(to: topic_path(conn, :index))
  end

  defp insert_or_update_user(changeset) do
    #below will return either a user or a nil,
    #if it returns nil, then insert that change, if it returns user then return a user
    case Repo.get_by(User, email: changeset.changes.email) do
      nil ->
        Repo.insert(changeset)
      user ->
        #why return tuple {:ok, user }
        {:ok, user}
    end
  end
end

#plug- a function that does a tiny transformation on our connection object
#Phoenix is based almost entirely on plugs
#types:
#1. Module plugs-
    # It should have two functions defined- init and call
    #init- to do some setup
    #call- Called with a 'conn', must return a conn
#2. Function plugs
    # plug which is a singular function. It's useful to make a singular plug whenever
    # you expect to use a plug only inside of your module