
require('dotenv').config()
program = require 'commander'
requestPromise = require 'request-promise'
global.request = requestPromise.defaults
  jar: true

signIn = require './sign_in'
downloadSeries = require './download'

program.parse process.argv

if program.args.length == 0
  return console.error("Pass a url to an egghead series")

run = ->
  await signIn()
  await downloadSeries program.args[0]
  console.log "\x07"
  console.log "All Done 🎉"

run()
