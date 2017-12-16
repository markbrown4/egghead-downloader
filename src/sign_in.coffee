
cheerio = require 'cheerio'
sign_in_url = 'https://egghead.io/users/sign_in'

get = () ->
  html = await request(uri: sign_in_url)
  $ = cheerio.load(html)
  $('meta[name=csrf-token]').attr('content')

post = (token) ->
  console.log "Signing in:  #{process.env.EMAIL}"
  request
    method: 'POST'
    uri: sign_in_url
    form:
      "authenticity_token": token
      "user[email]": process.env.EMAIL
      "user[password]": process.env.PASSWORD
    simple: false

signIn = ->
  token = await get()
  post(token)

module.exports = signIn
