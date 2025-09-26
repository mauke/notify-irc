from perl:5.42-slim

workdir /app
copy notify-irc .

entrypoint ["perl", "/app/notify-irc"]
