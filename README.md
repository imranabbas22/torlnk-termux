<p align="center">
  <img src="preview/splash.svg" alt="torlink, curated torrents straight from your terminal" style="max-width: 832px; width: 100%; height: auto;">
</p>

# torlnk-termux

**torlink** — a zero-setup torrent finder and downloader — packaged for **Termux on Android**.

Finding a torrent these days sucks. One site is a minefield of fake download buttons. Another hides the real link under a popup that spawns two more tabs. And after all that, half the results are dead, zero seeders.

torlink lives in your terminal, zero setup, nothing to configure. One search checks a short curated list of reputable sources at once, and whatever you pick downloads straight to your phone.

## Usage on Termux

From **Termux**, just run:

```sh
npx github:imranabbas22/torlnk-termux
```

Or install globally:

```sh
npm install -g github:imranabbas22/torlnk-termux
torlnk-termux
```

> **First run may take 1-2 min** while native modules compile. WebRTC warnings are normal — torlink falls back to TCP/uTP and DHT seamlessly.

## Termux notes

- **Node version** — `pkg install nodejs` gives you Node.js. v22+ recommended.
- **Storage** — Run `termux-setup-storage` once, then inside torlink press `o` and enter `~/storage/downloads/torlink` to save to shared storage.
- **Downloads** — Defaults to `~/Downloads/torlink/`. Change anytime with the `o` key.
- **WebRTC** — Native module rarely compiles on Android. torlink works fine over TCP/uTP and DHT.
- **First time?** Press `?` inside torlink for the full keybinding list.

## Headless

torlink also runs without the TUI, for servers and seedboxes:

    torlnk-termux watch <dir>    download anything dropped into a folder
    torlnk-termux serve          take magnets over HTTP
    torlnk-termux files          stream finished downloads over HTTP
    torlnk-termux attach         keep the TUI alive across ssh sessions

Add `--daemon` to keep watch, serve, or files running after you log out.

## Building from source

```sh
git clone https://github.com/imranabbas22/torlnk-termux.git
cd torlnk-termux
npm install
npm run build
npm start
```

## Credits

Based on [baairon/torlink](https://github.com/baairon/torlink) with Termux/Android patches.
