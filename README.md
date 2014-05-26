# TweetSnipper

Deletes Tweets older than hashtag specified duration, in the form of `/#\d+[hmd]/`.

Note: Does not work when deployed on Heroku.

# Installation

1. Clone repository.

		$ git clone https://github.com/iphoting/TweetSnipper
		$ cd TweetSnipper

2. Create a Twitter API application [here](https://apps.twitter.com/app/new).

3. Create a `.env` file within the clone with the following details:

```
TWITTER_USERNAME="username"
CONSUMER_KEY="API_key..."
CONSUMER_SECRET="API_secret..."
ACCESS_TOKEN="12345-xxyyy"
ACCESS_SECRET="09384xxyy"
```

4. Use bundler to fetch dependencies.

		$ bundle install

5. Run the app.

		$ ruby tweetsnipper.rb

6. Add the app to cron or launchd.
