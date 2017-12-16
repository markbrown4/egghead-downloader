
cheerio = require 'cheerio'
uri = 'https://egghead.io/users/sign_in'

get = () ->
  request({ uri }).then (html)->
    $ = cheerio.load(html)
    csrf = $('meta[name=csrf-token]').attr('content')

post = (token) ->
  console.log "signing in as #{process.env.EMAIL}"
  request
    method: 'POST'
    uri: 'https://egghead.io/users/sign_in'
    form:
      "authenticity_token": token
      "user[email]": process.env.EMAIL
      "user[password]": process.env.PASSWORD
    simple: false,
    resolveWithFullResponse: true

module.exports = () ->
  get().then(post)
