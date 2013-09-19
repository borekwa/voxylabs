
# define the views that are used in the Voxy Labs application

UploadVideoView = Parse.View.extend(
  el: $("#admin-body")
  
  initialize: ->
    @render
    
  render: ->
    alert "upload video view wants to render"
    
)
