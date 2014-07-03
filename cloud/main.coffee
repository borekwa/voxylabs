
twilio = require "twilio"
#twilio.initialize "AC63d8a06d5b00148b5d6b76da58f3a3c7","eadc01fbcf6742acf56eddbd9e811d32" #test credentials
twilio.initialize "ACe109988ea9b5503ec35864f6ff6b29ef","1e2275664405bee94472737853e2c415" #production credentials

Parse.Cloud.define "sendTwilioMsg", (request, response) ->
  numbers = request.params.numbers
  twilio.sendSMS
    to: numbers
    #from: "+15005550006" #test number
    from: "+19177913141" #production number
    body: request.params.message
  , 
    success: (httpResponse) ->
      response.success request.params.message
    error: (error, httpResponse) ->
      response.error error
  
  
