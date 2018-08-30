defmodule Discuss.Plugs.SetUser do 
  #SetUser Plug- the sole purpose of the plug is to look at our connection object, 
  #see if there is a user id assigned to it, and if there is, we are going to find that user
  #in our database and then assign it to the connection object. 
  #so that any other follow up operation, pipeline,we will have accesss to our user object.

  import Plug.Conn
  import Phoenix.Controller


  alias Discuss.Repo
  alias Discuss.User


  def init(_params) do

  end

  def call(conn, _params) do
  #the second argument _params is not like that used in any other controller.
  #but it is the return value of whatever comes back to init function. 
  #inside of this function we put some logic that attempts to pull user out of our db
  # if it does, assign it to the connection, otherwise, say no user here
  user_id = get_session(conn, :user_id)

  cond do
    user = user_id && Repo.get(User, user_id) ->
      assign(conn, :user, user)
    true ->
      assign(conn, :user, nil)

  end

  end
end
#in the auth controller we have access to user_id in session inside the sigin function, but not access to all the information 
#related to that particular user
#why plug?- goal is to look into the connection, grab the user_id out of the session and fetch that user out of our database
# and then we are going to do a tiny transfomr of the connection object and set that user model on that connection object 
# so that any other following plug, controller, any function, anywhere, we will automatically have access to the user model 
# on conn object. 