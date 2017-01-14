
require('dotenv').config()
request = require 'request'
program = require 'commander'

signIn = require './sign_in'
downloadSeries = require './download'

request.defaults
  jar: true
  rejectUnauthorized: false
  followAllRedirects: true

program.parse process.argv

if program.args.length == 0
  return console.error("Pass a url to an egghead series")

signIn ->
  downloadSeries program.args[0], ->
    console.log "\x07"
    console.log "All Done"
