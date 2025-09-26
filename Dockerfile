from perl:5.42-slim

workdir /usr/src/app
copy notify-irc .

entrypoint ["/usr/local/bin/perl", "/usr/src/app/notify-irc"]
