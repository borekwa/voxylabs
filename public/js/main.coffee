
#Router, Models, Views and events for the Voxy Labs application

#Map the Router
class Router extends Parse.Router
  routes:
    "": "home"
    "upload": "uploadVideo"
    "videos": "videoExperiment"
    "video-results": "videoResults"
    "video-feedback/:id": "videoFeedback"
    "admin": "admin"
    "speaking": "speakingSurvey"
  home: ->
    homeView = new HomeView()
  uploadVideo: ->
    uploadVideoView = new UploadVideoView()
  videoExperiment: ->
    videoExperimentView = new VideoExperimentView()
  videoResults: ->
    videoResultsView = new VideoResultsCollectionView()
  videoFeedback: (id) ->
    query = new Parse.Query(Video)
    query.get id,
      success: (video) ->
        videoFeedbackView = new VideoFeedbackView(model:video)
  admin: ->
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
  
#declare relevant Models (aka Parse.Objects)

class Video extends Parse.Object
  className: "Video"
  defaults:
    "likes": 0
    "dislikes": 0
    "startTime": null,
    "stopTime": null,
  uploadVideo: (video, title, description, videoUrl) ->
    video = video
    title = title
    description = description
    videoUrl = videoUrl
    video.set "title", title
    video.set "description", description
    video.set "videoUrl", videoUrl
    video.save null,
      success: (video) ->
        alert "video saved!"
      error: (video, error) ->
        alert "Error uploading the video: #{error}"
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
  goToUpload: (e) ->
    e.preventDefault()
    router.navigate "upload", true
  goToVideoResults: (e) ->
    e.preventDefault()
    router.navigate "video-results", true

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
  uploadVideo: (e) ->
    e.preventDefault()
    video = new Video
    title = $("#video-title-input").val()
    description = $("#video-description-input").val()
    videoUrl = $("#video-url-input").val()
    video.uploadVideo(video, title, description, videoUrl)
    router.navigate "upload", true
    
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
    router.navigate "video-feedback/"+id, true
    
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
  
router = new Router
Parse.history.start()
