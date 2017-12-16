
https   = require 'https'
fs      = require 'fs'
url     = require 'url'
path    = require 'path'
mkdirp  = require 'mkdirp'
async   = require 'async'
cheerio = require 'cheerio'
os      = require 'os'

downloadSeries = (url, callback)->
  fetchLinks(url).then (links)->
    threadCount = os.cpus().length
    async.eachLimit links, threadCount, (link, next)->
      downloadVideo(link, next)
    , callback

fetchLinks = (url)->
  parts = url.split('/')
  series = parts[parts.length - 1]

  console.log "Fetching: #{url}"
  request(url).then (html)->
    $ = cheerio.load(html)

    links = []
    $('a[href*="/lessons/"][id]').each (index, link)->
      index = ('0' + (index + 1)).substr(-2)
      links.push
        href: "https://egghead.io#{$(this).attr('href')}"
        series: series
        index: index

    links

downloadVideo = (link, next)->
  getVideoPaths(link)
    .then ({ videoUrl, filePath })->
      writeFile videoUrl, filePath, next
    .catch(next)

getVideoPaths = (link)->
  # console.log "fetching: #{link.href}"
  request(link.href).then (html)->
    # debug
    # mkdirp.sync "tmp/#{link.series}"
    # fs.writeFileSync "tmp/#{link.series}/#{link.index}.html", html

    if html.indexOf('This Lesson is for PRO Members.') > -1
      throw new Error('This Lesson is for PRO Members.')

    videoUrl = getVideoUrl(html)
    fileName = path.basename(url.parse(link.href).pathname) + '.mp4'
    filePath = "videos/#{link.series}/#{link.index}-#{fileName}"
    mkdirp.sync "videos/#{link.series}"

    { videoUrl, filePath }

getVideoUrl = (html)->
  $ = cheerio.load(html)
  json = JSON.parse $('.js-react-on-rails-component').html()

  return json.lesson.download_url

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

module.exports = downloadSeries
