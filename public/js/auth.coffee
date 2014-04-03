Parse.initialize "dUvUFnSWHPhwoLyhu6a4wlrsxF0Hu5JDRorzUBGC", "l5cOwMTe96qJ5VmTVjU8K9GByQ9nDUdUMj91b5PD"

currentUser = Parse.User.current()

$("#login-btn").click ->
  email = $("#login-email-input").val()
  password = $("#login-password-input").val()
  Parse.User.logIn email,password, 
    success: (user) ->
      console.log "successfully logged in!"
      window.location.replace "labs.html#admin/dashboard"
    error: (user,error) ->
      console.log "login failed"

$("#create-account-link").click ->
  email = $("#login-email-input").val()
  username = $("#login-email-input").val()
  password = $("#login-password-input").val()
  user = new Parse.User()
  user.set "email", email
  user.set "username", username
  user.set "password", password
  user.signUp null,
    success: (user) ->
      console.log "a new user signed up"
      window.location.replace "labs.html#admin/dashboard"
    error: (user, error) ->
      console.log "the following error occurred #{error}"

$("#log-out").click ->
  Parse.User.logOut()
