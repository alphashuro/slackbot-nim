import httpclient
import json
import strtabs 
import parseopt2
import parsecfg
import os

var slack_url: string
var channel: string
var text: string

var config_file_path = getConfigDir() & "slackbot.conf"

try:
  let config = loadConfig(config_file_path)
  slack_url = config.getSectionValue("", "webhook_url")
  channel = config.getSectionValue("", "default_channel")
except IOError: echo "Can't read the config file"

if slack_url == nil: quit "webhook_url was not set in slackbot.conf"

for kind, key, val in get_opt():
  case kind

  of cmdArgument:
    # if there is only one argument its probably the message
    text = if key != nil: key
                    else: readAll(stdin) # else read input from stdin as the messasge, so we can use pipe operator

  of cmdLongOption, cmdShortOption:
    case key
    of "channel", "c": channel = val
    of "message", "m": text = val
    of "url", "u": slack_url = val

  of cmdEnd: assert(false) # cannot happen

let client = newHttpClient()
client.headers = newHttpHeaders({ "Content-Type": "application/json" })

let body = %*{
    "channel": channel,
    "text": text,
    "username": "the terminator",
    "icon_emoji": ":robot_face:"
}

echo client.request(httpMethod = HttpPost, url = slack_url, body = $body)