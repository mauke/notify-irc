# Send Notification Message to IRC

This action implements just enough of the IRC protocol to automatically send a
message from a workflow. It is implemented as a Docker container, so it [needs to
execute on a Linux runner](https://docs.github.com/en/actions/concepts/workflows-and-actions/custom-actions#docker-container-actions).

To use it, include it as one of the steps in your workflow:

```yaml
jobs:
  foo:
    runs-on: ubuntu-latest
    steps:
      - name: "irc push"
        if: github.event_name == 'push'
        uses: mauke/notify-irc@v1.1
        with:
          server: 'irc.example.com'
          port: 6697
          tls: true
          nickname: 'my-herald'
          channel: '#announcements'
          join: true
          message: |
            ${{ github.actor }} pushed ${{ github.event.ref }} ${{ github.event.compare }}
            ${{ join(github.event.commits.*.message) }}
…
```

The following configuration parameters can be set in the `with` section:

- `server` (required)

  The name of the IRC server to connect to.

- `port` (required)

  The port to connect to. This is usually `6667` for plaintext connections, but
  varies between servers for encrypted connections.

- `tls`

  Set this to `true` if the connection should be encrypted with TLS (née SSL).
  The default is to use an unencrypted (plaintext) connection.

- `password`

  The server password to use. Most servers don't require a password to connect,
  but on some servers the connection password can be used to automatically log
  into a NickServ account.

- `nickname` (required)

  The nickname that the bot should use.

- `channel` (required)

  The target to send the notification message to, which is usually a channel.
  (But if you want, you can set this to your nickname instead.)

- `join`

  Set this to `true` if the notification bot should join the specified
  `channel` before speaking. This is normally what you want, but there are some
  cases where joining is not desired:

  - The notification target (`channel`) is not actually a channel, but the name
    of a user. In that case "joining" makes no sense.
  - The notification target is a channel without mode `+n`. If `+n` is not
    enabled, users who are not joined to the channel are allowed to speak in
    it. Joining first is still allowed, of course, but not joining saves on
    some join/part noise around notifications.

- `channel_key`

  The channel password or "key" to use if the specified `channel` has mode `+k`
  enabled (requires a key to join). (Setting this parameter is pointless
  without `join: true`.)

- `message` (required)

  The message to send. This can be a multi-line string, in which case every
  line is sent as a separate message.

  Note that message throttling is not implemented, so if you specify too many
  lines here, the IRC server may automatically disconnect the notification bot
  before it can send everything (flood protection).

- `notice`

  Set this to `true` if notifications should be sent using `NOTICE` instead of
  `PRIVMSG`. Technically `NOTICE` is the correct message type to use for bots
  and automated messages, but most IRC clients implement it wrong: Instead of
  displaying it like a normal message or giving it lower priority, they
  highlight it or blink an icon or trigger a sound alert, etc. That's why this
  action defaults to `PRIVMSG`, i.e. normal messages.

- `verbose`

  Set this to `true` if you want to debug this action. Causes every
  sent/received IRC message to be logged on stderr.
