# PushIt

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

[![wercker status](https://app.wercker.com/status/183fcb9b8bc0678d9571d1fa8d29ff59/s "wercker status")](https://app.wercker.com/project/bykey/183fcb9b8bc0678d9571d1fa8d29ff59)

## Overview

A super light-weight Apple push notification service.

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

## How to pass .pem via environment variables

### Local

    $ export APN_CERTIFICATE_BASE64=`bundle exec rake APN_CERTIFICATE=/path/to/aps_developer_identity.pem`
    $ PORT=4567 bundle exec foreman start

### Heroku

    $ heorku create
    $ git push heroku master
    $ heroku config:add APN_CERTIFICATE_BASE64=`bundle exec rake APN_CERTIFICATE=/path/to/aps_developer_identity.pem`
    $ heroku config:add APN_CERTIFICATE=tmp/apple_push_notification.pem

## How to Push

    $ curl -XPOST https://yourapp.herokuapp.com/message \
      -H 'Content-Type: application/json' \
      -d '{
        "tokens":["xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx xxxxxxxx"],
        "payload": {
          "aps" : {
            "alert" : "Yo",
            "badge" : 0,
            "sound" : "default",
          },
          "my_data" : "my_string"
        }
      }'

## Acknowledge
This code is extracted from [Helios](http://helios.io/) by Mattt Thompson.

