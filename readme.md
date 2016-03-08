# Egghead.io video downloader

If you have a pro account with egghead.io you can download a HD video series for later viewing.

Update `.env` with your email and password and run the script with the url of a video series e.g.

```bash
npm install
npm install -g coffee-script
coffee index.coffee https://egghead.io/series/getting-started-with-redux
```

You can adjust `THREADS` in `.env` to control how many videos are downloaded at once.
