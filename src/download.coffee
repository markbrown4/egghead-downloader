
https   = require 'https'
fs      = require 'fs'
url     = require 'url'
path    = require 'path'
mkdirp  = require 'mkdirp'
async   = require 'async'
cheerio = require 'cheerio'
os      = require 'os'

series_base_url = 'https://egghead.io/api/v1/series'
current_user_url = 'https://egghead.io/current_user'

downloadSeries = (url)->
  new Promise (resolve) ->
    links = await fetchLinks(url)
    threadCount = os.cpus().length

    async.eachLimit links, threadCount, (link, next)->
      downloadVideo(link, next)
    , resolve

fetchLinks = (url)->
  parts = url.split('/')
  series_id = parts[parts.length - 1]

  # Check to see if user has a Pro account
  current_user = await request(current_user_url)
  unless JSON.parse(current_user).is_pro == true
    console.log("Sorry, You need a PRO account to download videos.")
    return []

  # Fetching the lessons url
  console.log "Fetching lessons from: #{url}"
  lessons_url = "#{series_base_url}/#{series_id}/lessons"

  res = await request({
    uri: lessons_url,
    headers: {
      'Origin': 'https://egghead.io'
    }
   })

  directory = "videos/#{series_id}"
  console.log("\nWriting: #{directory}")
  mkdirp.sync directory

  return JSON.parse(res).map (lesson, index)->
    url: lesson.http_url
    series: series_id
    index: ('0' + (index + 1)).substr(-2)

downloadVideo = (link, next) ->
  try
    file = await getVideoDetails(link)
    writeFile file, next
  catch err
    next()

getVideoDetails = (link) ->
  console.log "fetching: #{link.url}"
  html = await request(link.url)

  # debug
  # mkdirp.sync "tmp/#{link.series}"
  # fs.writeFileSync "tmp/#{link.series}/#{link.index}.html", html

  $ = cheerio.load(html)
  json = JSON.parse $('.js-react-on-rails-component').html()

  videoUrl = await request(json.lesson.download_url)
  videoName = path.basename(url.parse(link.url).pathname)
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
