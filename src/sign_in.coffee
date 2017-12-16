
cheerio = require 'cheerio'
sign_in_url = 'https://egghead.io/users/sign_in'

get = () ->
  request
    uri: sign_in_url
  .then (html)->
    $ = cheerio.load(html)
    $('meta[name=csrf-token]').attr('content')

post = (token) ->
  console.log "signing in as #{process.env.EMAIL}"
  request
    method: 'POST'
    uri: sign_in_url
    form:
      "authenticity_token": token
      "user[email]": process.env.EMAIL
      "user[password]": process.env.PASSWORD
    simple: false,
    resolveWithFullResponse: true

module.exports = () ->
  get().then(post)
