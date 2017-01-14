
request = require 'request'
cheerio = require 'cheerio'

get = (callback)->
  request "https://egghead.io/users/sign_in", (error, response, html)->
    $ = cheerio.load(html)
    token = $('input[name=authenticity_token]').val()

    callback token

post = (token, callback)->
  console.log "signing in as #{process.env.EMAIL}"
  request.post "https://egghead.io/users/sign_in",
    form:
      "utf8": "✓"
      "authenticity_token": token
      "user[email]": process.env.EMAIL
      "user[password]": process.env.PASSWORD
  , callback

module.exports = (callback)->
  get (token)->
    post token, callback
