
https   = require 'https'
fs      = require 'fs'
url     = require "url"
path    = require "path"
mkdirp  = require "mkdirp"
async   = require 'async'
cheerio = require 'cheerio'
os      = require 'os'

getPaths = (link, callback)->
  console.log "fetching: #{link.href}"
  request link.href, (error, response, html)->
    $ = cheerio.load(html)
    contentUrl = $("meta[itemprop=contentURL]").attr('content')
    regex = /deliveries\/(.*)+\.bin/
    id = contentUrl.match(regex)[1]
    videoUrl = "https://embedwistia-a.akamaihd.net/deliveries/#{id}/file.mp4"
    fileName = path.basename(url.parse(link.href).pathname) + '.mp4'
    filePath = "videos/#{link.series}/#{link.index}-#{fileName}"
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

downloadVideo = (link, callback)->
  getPaths link, (videoUrl, filePath)->
    writeFile videoUrl, filePath, callback

fetchIndex = (url, callback)->
  parts = url.split('/')
  series = parts[parts.length - 1]

  console.log "Fetching: #{url}"
  request url, (error, response, html)->
    $ = cheerio.load(html)

    links = []
    $('#lesson-list td.cell-lesson-title a').each (index, link)->
      index = ('0' + (index + 1)).substr(-2)
      links.push
        href: $(this).attr('href')
        series: series
        index: index

    callback(links)

downloadSeries = (url, callback)->
  fetchIndex url, (links)->
    threadCount = os.cpus().length
    async.eachLimit links, threadCount, (link, next)->
      downloadVideo(link, next)
    , callback

module.exports =
  downloadVideo: downloadVideo
  downloadSeries: downloadSeries
