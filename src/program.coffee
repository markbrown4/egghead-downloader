
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

signIn().then () ->
  downloadSeries program.args[0], () ->
    console.log "\x07"
    console.log "All Done"
