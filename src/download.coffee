
https   = require 'https'
fs      = require 'fs'
url     = require 'url'
path    = require 'path'
mkdirp  = require 'mkdirp'
async   = require 'async'
cheerio = require 'cheerio'
os      = require 'os'

downloadSeries = (url)->
  new Promise (resolve) ->
    links = await fetchLinks(url)
    threadCount = os.cpus().length

    async.eachLimit links, threadCount, (link, next)->
      downloadVideo(link, next)
    , resolve

fetchLinks = (url)->
  parts = url.split('/')
  series = parts[parts.length - 1]

  console.log "Fetching: #{url}"
  html = await request(url)
  $ = cheerio.load(html)

  unless html.includes("'PRO Member': true")
    console.log("Sorry, You need a PRO account to download videos.")
    return []

  directory = "videos/#{series}"
  console.log("\nWriting: #{directory}")
  mkdirp.sync directory

  Array.from $('a[href*="/lessons/"][id]').map (index)->
    href: "https://egghead.io#{$(this).attr('href')}"
    series: series
    index: ('0' + (index + 1)).substr(-2)

downloadVideo = (link, next) ->
  try
    file = await getVideoDetails(link)
    writeFile file, next
  catch err
    next()

getVideoDetails = (link) ->
  # console.log "fetching: #{link.href}"
  html = await request(link.href)

  # debug
  # mkdirp.sync "tmp/#{link.series}"
  # fs.writeFileSync "tmp/#{link.series}/#{link.index}.html", html

  $ = cheerio.load(html)
  json = JSON.parse $('.js-react-on-rails-component').html()

  videoUrl = json.lesson.download_url
  videoName = path.basename(url.parse(link.href).pathname)
  fileName = "#{link.index}-#{videoName}.mp4"
  filePath = "videos/#{link.series}/#{fileName}"

  return { videoUrl, fileName, filePath }

writeFile = ({ videoUrl, filePath, fileName }, callback)->
  try
    stats = fs.lstatSync(filePath)
    console.log "Skipping: #{fileName}"
    callback()
  catch err
    console.log "Downloading: #{fileName}"

    file = fs.createWriteStream(filePath)
    https.get videoUrl, (resp)->
      resp.pipe(file)
      file.on 'finish', ->
        file.close()
        callback()

module.exports = downloadSeries
