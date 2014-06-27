# PushIt
Super light-weight Apple Push Notification Service.

## Feature

* No database
* No configurations
* No UI

## Deploying Heroku

    $ heorku create
    $ cp apple_push_notification.pem .
    $ git add .
    $ git commit -am "Add .pem"
    $ git push heroku master

If you use production .pem:

    $ heroku config:add APN_ENVIRONMENT=production

## How to Push

    $ curl -XPOST https://yourapp.herokuapp.com/messages \
      -H 'Content-Type: application/json' \
      -d '{
        "tokens":["xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx"],
        "payload": {
           "apns" : {
             "alert" : "Hello world",
             "badge" : 0,
             "sound" : "default"
           }
        }"
      }'

## Acknowledge
This code is extracted from [Helios](http://helios.io/) by Mattt Thompson.

