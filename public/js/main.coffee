Parse.initialize "dUvUFnSWHPhwoLyhu6a4wlrsxF0Hu5JDRorzUBGC", "l5cOwMTe96qJ5VmTVjU8K9GByQ9nDUdUMj91b5PD"

#Router, Models, Views and events for the Voxy Labs application

#Map the Router
class Router extends Parse.Router
  routes:
    "": "home"
    "admin/video-upload": "uploadVideo"
    "admin/video-results": "videoResults"
    "admin/video-results/video-feedback/:id": "videoFeedback"
    "admin/dashboard": "admin"
    "admin/lingping": "sendSms"
    "videos": "videoExperiment"
    "speaking": "speakingSurvey"
  home: ->
    homeView = new HomeView()
  uploadVideo: ->
    currentUser = Parse.User.current()
    if currentUser is null
      window.location.replace "admin-login.html"
    uploadVideoView = new UploadVideoView()
  videoExperiment: ->
    videoExperimentView = new VideoExperimentView()
  videoResults: ->
    currentUser = Parse.User.current()
    if currentUser is null
      window.location.replace "admin-login.html"
    videoResultsView = new VideoResultsCollectionView()
  videoFeedback: (id) ->
    currentUser = Parse.User.current()
    if currentUser is null
      window.location.replace "admin-login.html"
    query = new Parse.Query(Video)
    query.get id,
      success: (video) ->
        videoFeedbackView = new VideoFeedbackView(model:video)
  admin: ->
    currentUser = Parse.User.current()
    if currentUser is null
      window.location.replace "admin-login.html"
    query = new Parse.Query(Video)
    query.find
      success: (results) ->
        i = 0
        totalLikes = 0
        totalDislikes = 0
        while i < results.length
          video = results[i]
          videoLikes = video.get "likes"
          videoDislikes = video.get "dislikes"
          totalLikes += videoLikes
          totalDislikes += videoDislikes
          i++
        videoExperimentData =
          totalLikes: totalLikes
          totalDislikes: totalDislikes          
        adminView = new AdminView(videoExperimentData: videoExperimentData)
  speakingSurvey: ->
    speakingSurveyView = new SpeakingSurveyView()
  sendSms: ->
    sendSmsView = new SendSmsView()
  
#declare relevant Models (aka Parse.Objects)

class Video extends Parse.Object
  className: "Video"
  defaults:
    "likes": 0
    "dislikes": 0
    "startTime": 0,
  uploadVideo: (video, title, description, videoUrl, startTime) ->
    video.set "title", title
    video.set "description", description
    video.set "videoUrl", videoUrl
    video.set "startTime", startTime
    video.save null,
      success: (video) ->
        alert "video saved!"
      error: (video, error) ->
        alert "Error uploading the video: "+error
  likeVideo: ->
    @increment "likes"
    @save null,
      success: ->
        console.log "+1 video like"
      error: (video, error) ->
        console.log "Error liking the video: {#error}"
  dislikeVideo: ->
    @increment "dislikes"
    @save null,
      success: ->
        console.log "+1 video dislike"
      error: (video, error) ->
        console.log "Error disliking the video: {#error}"
  submitPositiveFeedback: (feedback) ->
    @add "positiveFeedback", feedback
    @save null,
      success: ->
        console.log "positive feedback added to object"
      error: (video, error) ->
        console.log "Error submitting feedback: {#error}"
  submitNegativeFeedback: (feedback) ->
    @add "negativeFeedback", feedback
    @save null,
      success: ->
        console.log "negative feedback added to object"
      error: (video, error) ->
        console.log "Error submitting feedback: {#error}"

#create global Views
class HomeView extends Parse.View
  el: "#container"
  template: $("#labs-home-template").html()
  initialize: ->
    @render()
  render: ->
    template = _.template(@template)
    @$el.html template
  events:
    "click #video-lesson-experiment": "goToVideos"
    "click #speaking-survey": "goToSpeaking"
    #"click #notifications-survey: "goToNotifications""
  goToVideos: (e) ->
    e.preventDefault()
    router.navigate "videos", true
  goToSpeaking: (e) ->
    e.preventDefault()
    router.navigate "speaking", true
  #goToNotifications: ->
    #router.navigate "notifications", true

class AdminView extends Parse.View
  el: "#container"
  template: $("#labs-admin-template").html()  
  initialize: (options) ->
    @videoExperimentData = options.videoExperimentData
    @render()
  render: ->
    template = _.template(@template)
    @$el.html template(@videoExperimentData)
  events:
    "click #upload-video-link": "goToUpload"
    "click #video-experiment-widget": "goToVideoResults"
    "click #ling-ping-widget": "goToLingPing"
    "click #log-out": "logOut"
  goToUpload: (e) ->
    e.preventDefault()
    router.navigate "admin/video-upload", true
  goToVideoResults: (e) ->
    e.preventDefault()
    router.navigate "admin/video-results", true
  goToLingPing: (e) ->
    e.preventDefault()
    router.navigate "admin/lingping", true
  logOut: (e) ->
    e.preventDefault()
    Parse.User.logOut()
    window.location.replace "admin-login.html"
    
class UploadVideoView extends Parse.View
  el: "#admin-body"
  template: $("#upload-video-template").html()
  initialize: ->
    @render()
  render: ->
    template = _.template(@template)
    @$el.html(template())
    $("#video-url-input").focus()
  events:
    "click #upload-video-btn": "uploadVideo"
    "keyup #video-description-input": "countDescriptionCharacters"
    "keyup #video-title-input": "countTitleCharacters"
  uploadVideo: (e) ->
    e.preventDefault()
    video = new Video
    title = $("#video-title-input").val()
    description = $("#video-description-input").val()
    videoUrl = $("#video-url-input").val()
    startTime = $("#video-start-time-input").val()
    video.uploadVideo(video, title, description, videoUrl, startTime)
    router.navigate "admin/video-upload", true
  countTitleCharacters: (e) ->
    e.preventDefault()
    max = 58
    count = $("#video-title-input").val().length
    $("#video-title-characters").text(max-count)
    $("#video-title-characters").css "color":"red" if max-count < 0
    $("#video-title-characters").css "color":"" if max-count > 0
  countDescriptionCharacters: (e) ->
    e.preventDefault()
    max = 108
    count = $("#video-description-input").val().length
    $("#video-description-characters").text(max-count)
    $("#video-description-characters").css "color":"red" if max-count < 0
    $("#video-description-characters").css "color":"" if max-count > 0   
    
class VideoCollection extends Parse.Collection
  model: Video
  sort_key: "id" # default sort key
  comparator: (item) ->
    -item.get @sort_key
  sortByField: (fieldName) ->
    @sort_key = fieldName
    @sort()
    
class ExperimentView extends Parse.View
  el: "#container"
  template: $("#experiment-template").html()
  initialize: ->
    @render()
  render: ->
    template = _.template(@template)
    @$el.html(template())    
    
class VideoExperimentView extends Parse.View
  el: "#container"
  headerTemplate: $("#video-header-template").html()
  initialize: ->
    @render()
    @collection = new VideoCollection
    @collection.fetch
      success: (videoCollection) ->
        videoCollectionView = new VideoCollectionView(collection:videoCollection)
      error: (videoCollection, results) ->
        console.log "error fetching the video collection"
  render: ->
    headerTemplate = _.template(@headerTemplate)
    @$el.html headerTemplate
    
class VideoCollectionView extends Parse.View
  el: "#container"
  initialize: ->
    @collection.reset @collection.shuffle(),
      silent: true
    @render()
  render: ->
    @collection.each ((video) ->
      @renderVideo video
    ), @    
  renderVideo: (video) ->
    videoModelView = new VideoModelView(model: video)
    @$el.append(videoModelView.render().el)
        
class VideoModelView extends Parse.View
  template: $("#video-model-template").html()
  initialize: ->
    #do nothing
  render: ->
    template = _.template(@template)
    @$el.html template(@model.toJSON())
    @$(".thanks").hide()
    @$(".positive-feedback-form").hide()
    @$(".negative-feedback-form").hide()
    @
  events:
    "click .thumbs-up":"like"
    "click .thumbs-down":"dislike"
    "click .positive-feedback-submit":"submitPositiveFeedback"
    "click .negative-feedback-submit":"submitNegativeFeedback"
  like: ->
    @model.likeVideo()
    @$(".like-dislike").hide()
    @$(".positive-feedback-form").show()
    @$(".feedback-form").focus()
  dislike: ->
    @model.dislikeVideo()
    @$(".like-dislike").hide()
    @$(".negative-feedback-form").show()
    @$(".feedback-form").focus()
  submitPositiveFeedback: ->
    feedback = @$(".positive-feedback-input").val()
    @model.submitPositiveFeedback(feedback)
    @$(".positive-feedback-form").hide()
    @$(".thanks").show()
  submitNegativeFeedback: ->
    feedback = @$(".negative-feedback-input").val()
    @model.submitNegativeFeedback(feedback)
    @$(".negative-feedback-form").hide()
    @$(".thanks").show()
    
class VideoResultsCollectionView extends Parse.View
  el: "#admin-body"
  template: $("#video-results-template").html()
  initialize: ->
    @render()
    @collection = new VideoCollection
    @collection.fetch
      success: (videoCollection) ->
        videoCollection.sortByField "likes"
        likedVideosView = new LikedVideosView(likedVideosCollection: videoCollection)
        videoCollection.sortByField "dislikes"
        dislikedVideosView = new DislikedVideosView(dislikedVideosCollection: videoCollection)
  render: ->
    template = _.template(@template)
    @$el.html(template())
    
class LikedVideosView extends Parse.View
  el: "#most-liked-videos"
  initialize: (options) ->
    @likedVideosCollection = options.likedVideosCollection
    @render()
  render: ->
    @likedVideosCollection.each ((video) ->
      @renderVideoResults video
    ), @
  renderVideoResults: (video) ->
    videoModelResultsView = new VideoModelResultsView(model: video)
    @$el.append(videoModelResultsView.render())
    
class DislikedVideosView extends Parse.View
  el: "#least-liked-videos"
  initialize: (options) ->
    @dislikedVideosCollection = options.dislikedVideosCollection
    @render()
  render: ->
    @dislikedVideosCollection.each ((video) ->
      @renderVideoResults video
    ), @
  renderVideoResults: (video) ->
    videoModelResultsView = new VideoModelResultsView(model: video)
    @$el.append(videoModelResultsView.render())
    
class VideoModelResultsView extends Parse.View
  template: $("#video-model-results-template").html()
  initialize: ->
    #do nothing
  render: ->
    template = _.template(@template)
    @$el.html template(@model.toJSON())
  events:
    "click .widget":"goToVideoFeedback"
  goToVideoFeedback: (e) ->
    e.preventDefault()
    id = @model.id 
    router.navigate "admin/video-results/video-feedback/"+id, true
    
class VideoFeedbackView extends Parse.View
  el: "#admin-body"
  template: $("#video-feedback-template").html()
  initialize: ->
    @render()
    negativeFeedback = @model.get "negativeFeedback"
    positiveFeedback = @model.get "positiveFeedback"
    comments = _.union negativeFeedback, positiveFeedback
    i = 0
    while i < comments.length
      comment = comments[i]
      videoCommentView = new VideoCommentView(comment: comment)
      videoCommentView.render()
      i++
    @    
  render: ->
    template = _.template(@template)
    @$el.html template(@model.toJSON())
  renderComment: (comment) ->
    videoCommentView = new VideoCommentView(
      comment: comment
    )
    videoCommentView.render()
    
class VideoCommentView extends Parse.View
  el: "#video-feedback-container"
  template: $("#video-comment-template").html()
  initialize: (options) ->
    @comment = options.comment
  render: ->
    template = _.template(@template)
    @$el.append template("comment": @comment)

class SpeakingSurveyView extends Parse.View
  el: $("#container")
  template: $("#speaking-survey-template").html()
  initialize: ->
    @render()
  render: ->
    template = _.template(@template)
    @$el.html template
  events: ->
    "change input":"changeRadio"
  changeRadio: (e) ->
    e.preventDefault()
    $(e.target).parent.addClass "bright-purple"
    
class SendSmsView extends Parse.View
  el: "#container"
  template: $("#send-sms-template").html()
  initialize: ->
    @render()
  render: ->
    template = _.template(@template)
    @$el.html template
    $("#sms-error").hide()
  events: ->
    "keyup #sms-message-input":"countMsgCharacters"
    "click #send-sms-btn":"sendSms"
  countMsgCharacters: (e) ->
    e.preventDefault()
    max = 160
    count = $("#sms-message-input").val().length
    $("#sms-msg-characters").text(max-count)
    $("#sms-msg-characters").css "color":"red" if max-count < 0
    $("#sms-msg-characters").css "color":"" if max-count >= 0
  sendSms: (e) ->
    e.preventDefault()
    confirm "Are you sure you want to send this SMS message to all specified learners?  This cannot be stopped or undone and charges will be incurred."
    
    file = $("#csv-input").get(0).files[0]
    message = $("#sms-message-input").val()
    
    if file
      reader = new FileReader()
      reader.readAsText file
      reader.onload = (e) ->
        csvArrays = $.csv.toArrays e.target.result
        
        i = 1
        successes = 0
        errors = 0
        while i < csvArrays.length
          number = csvArrays[i][0]
          Parse.Cloud.run "sendTwilioMsg",
            number: number
            message: message
          ,
            success: (response) ->
              $("#sms-error").hide()
              successes++
              $("#success-count").html successes 
              $("#message-log").append "<p>Message successfully sent to "+response+" at "+new Date()+"</p>"
              console.log "Message successfully sent"
            error: (error, number) ->
              string = error.message
              object = JSON.parse string
              $("#sms-error").show()
              $("#sms-error").html "Error: "+object.message
              $("#error-count").html errors++
              $("#message-log").append "<p class='labs-alert-danger'>Error sending to "+number+" at "+new Date()+" due to "+object.message+"</p>"
              console.log "cloud error: "+error.code+": "+object.message+", more info: "+object.more_info
          i++
        
    else
      numbers = $("#numbers-input").val()

      array = numbers.split ","
      i = 0
      successes = 0
      errors = 0
      while i < array.length
        Parse.Cloud.run "sendTwilioMsg",
          number: array[i]
          message: message
        ,
          success: (response) ->
            $("#sms-error").hide()
            successes++
            $("#success-count").html successes
            $("#message-log").append "<p>Message successfully sent to "+response+" at "+new Date()+"</p>"
            console.log "Message successfully sent"
          error: (error, number) ->
            string = error.message
            object = JSON.parse string
            $("#sms-error").show()
            $("#sms-error").html "Error: "+object.message
            $("#error-count").html errors++
            $("#message-log").append "<p class='labs-alert-danger'>Error sending to "+number+" at "+new Date()+" due to "+object.message+"</p>"
            console.log "cloud error: "+error.code+": "+object.message+", more info: "+object.more_info
        i++
  
router = new Router
Parse.history.start()
