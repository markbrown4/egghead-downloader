# Egghead.io video downloader

If you have a pro account with egghead.io you can download a HD video series for later viewing.

Create a .env file in the root directory
```
touch .env
```

Add your email and password to the file as following:
```
EMAIL=yourmail@gmail.com
PASSWORD=yourpassword
```

Install dependencies:
```bash
npm install
```

## Usage:
```bash
npm run download https://egghead.io/series/getting-started-with-redux
```

If you have VLC installed you can play the series from the terminal e.g.

```bash
vlc "videos/getting-started-with-redux"
```
