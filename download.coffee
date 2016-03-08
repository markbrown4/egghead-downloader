
https   = require 'https'
fs      = require 'fs'
url     = require "url"
path    = require "path"
mkdirp  = require "mkdirp"
async   = require 'async'
cheerio = require 'cheerio'

getPaths = (link, callback)->
  console.log "fetching: #{link.href}"
  request link.href, (error, response, html)->
    $ = cheerio.load(html)
    videoUrl = $('#clicker1').attr('href')
    fileName = path.basename(url.parse(videoUrl).pathname)
    filePath = "videos/#{link.series}/#{fileName}"
    mkdirp.sync "videos/#{link.series}"

    callback(videoUrl, filePath)

writeFile = (videoUrl, filePath, callback)->
  try
    stats = fs.lstatSync(filePath)
    console.log "skipping: #{filePath}"
    callback()
  catch err
    console.log "writing: #{filePath}"
    file = fs.createWriteStream(filePath)
    https.get videoUrl, (resp)->
      resp.pipe(file)
      file.on 'finish', ->
        file.close()
        callback()

downloadVideo = (lessonUrl, callback)->
  getPaths lessonUrl, (videoUrl, filePath)->
    writeFile videoUrl, filePath, callback

fetchIndex = (url, callback)->
  parts = url.split('/')
  series = parts[parts.length - 1]

  console.log "Fetching: #{url}"
  request url, (error, response, html)->
    $ = cheerio.load(html)

    links = []
    $('#lesson-list td.cell-lesson-title a').each (index, link)->
      links.push
        href: $(this).attr('href')
        series: series

    callback(links)

downloadSeries = (url, callback)->
  fetchIndex url, (links)->
    async.eachLimit links, process.env.THREADS, (link, next)->
      downloadVideo(link, next)
    , callback

module.exports =
  downloadVideo: downloadVideo
  downloadSeries: downloadSeries
