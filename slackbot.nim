import httpclient
import json
import strtabs, strutils
import parseopt2
import parsecfg
import os

var slack_url: string
var channel: string
var text: string
var token: string

var config_file_path = getConfigDir() & "slackbot.conf"

try:
  let config = loadConfig(config_file_path)
  slack_url = config.getSectionValue("", "webhook_url")
  channel = config.getSectionValue("", "default_channel")
  token = config.getSectionValue("", "token")
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

let api_url = "https://slack.com/api/"
let params = "pretty=true&token=$#" % token

let api_method = "channels.create"
let method_params = "name=$#" % [channel]
# let api_method = "chat.postMessage"
# let method_params = "as_use=true&channel=$#&text=$#" % [channel, text]

let url = api_url & api_method & "?" & params & "&" & method_params 

echo client.request(url)