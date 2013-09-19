
#define Models (aka Parse.Objects) to be used in the Voxy Labs application

Parse.initialize "dUvUFnSWHPhwoLyhu6a4wlrsxF0Hu5JDRorzUBGC", "l5cOwMTe96qJ5VmTVjU8K9GByQ9nDUdUMj91b5PD"

currentUser = Parse.User.current()

Video = Parse.Object.extend(
  className: "Video"
    
  uploadVideo: (embedUrl) ->
      alert "uploadVideo method invoked"
      video = new Video()
      
      #do I need a function to scrape the url and save title and description as variables
      #video.set "title", title
      #video.set "description", description
      video.set "embedUrl", embedUrl
      video.save null,
        success: (video) ->
          alert "video saved!"
        error: (video, error) ->
          alert "the following error occurred: #{error}"
)

