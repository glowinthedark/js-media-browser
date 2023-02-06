# MediaBrowser for Caddy

Mediabro for Caddy is a minimalistic web client that provides an easy way to browse files on a computer, and view videos, audios, PDFs, images and text content. The only server-side requirement is a vanilla [caddy server](https://caddyserver.com/) installation.

Mediabro does not aim to replace [Plex](https://www.plex.tv/), [Jellyfin](https://jellyfin.org/), [Dim](https://github.com/Dusk-Labs/dim), [Filebrowser](https://github.com/filebrowser/filebrowser), etc and instead relies on having a regular caddy instance running with an light browser-based client. 

The intended use is HTTP browsing of audio or video files with associated notes in PDF, HTML, Markdown, or plain text format. Clicking a media file will open it in the media preview panel and search for a matching PDF, HTML, etc file with the same base name. If a matching content file was found it will be loaded in the content preview panel below the media panel. You can also add your own matching rules by editing the code. 

This is a purely client-side web client which connects to a [caddy server](https://caddyserver.com/) via HTTP. 

<sup>The media browser can also be used with other HTTP servers but in that case an static `index.json` file must be provided in the folders to be browsed. For details see the [Implementation](#implementation) section below. </sup>

An example `/etc/caddy/Caddyfile` for caddy server:

```bash
http:// {

	root * /media

	file_server browse {
		root /media
		hide .git
		index ''
	}
	# required in chrome for allowing loading PDF files in an iframe
	header {
		X-Frame-Options SAMEORIGIN
	}
}
```

> NOTE: The caddy `file_server_browser` module must have the `index ''` instruction. Otherwise caddy will attempt to load existing `index.html` files (if present) instead of returning directory listings in JSON format as required by the client-side.

## Features:

* displaying PDF, HTML, Markdown content with associated audio/video files
* adjustable playback speed for media files
* resizable navigation and content panels
* markdown rendering for `.md` files
* syntax highlighting for source code files
* automatic detection and loading of WebVTT subtitles for video files

Example: if a folder contains a PDF file named `video-01.pdf` and a video file named `video-01.mp4`, then clicking the PDF file will display it in the content panel while the video will start playing in the media panel above. 

Additionally, if `video-01.en.vtt`, `video-01.es.vtt` etc are present in the same folder then subtitles will be picked up and can be selected via the subtitles submenu in the video controls.

## Supported media formats
Playback of media files is handled by the web browser therefore support is limited by the capabilities of the corresponding HTML5 `<audio/>` and `<video/>` elements which currently include: MP3, MP4 audio/video (H.264, AAC, MP3 codecs), MP4 container with Flac codec, OGG audio and video (Theora, Vorbis, Opus, Flac codecs), FLAC, WebM audio/video (VP8, VP9 codecs), WAV (PCM). Limited support for Matroska (MKV) is present for browsers that support it. 

For more details refer to [mozilla browser media compatibility table](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Video_codecs#common_codecs).

## Keyboard navigation shortcuts

| Key press  | Action |
| ------------- | ------------- |
| Left  | Seek backward 5 sec  |
| Right  | Seek forward 5 sec  |
| Up  | Seek forward 1 min  |
| Down  | Seek backward 1 min  |
| Space  | Pause/Play  |
| f  | Toggle full screen  |

## URL parameters

The URL can contain extra parameters:


| Param  | Description |
| ------------- | ------------- |
| **`hidden=true`**  | show files starting with a dot, e.g. `.vimrc`  |
| **`skip=12`**  | skip the first NN seconds  |
| **`pdfjs=true`**  | force opening files with pdf.js instead of the native PDF renderer  |
| **`filter=\.(html\|pdf\|jpg)`** | regex to only include files that match the expression, e.g. html, pdf and jpg |

> `true`, `1`, `yes`, `on` all have the same effect

Example URL with custom parameters which shows dot files, uses pdf.js for PDF rendering and skips the first 15 seconds on media playback: 


- `http://example.com/path/to/project/mediabro24caddy/index.html?hidden=true&skip=15&pdfjs=true#/path/to/content/`

## Implementation

Caddy is a fast, lightweight and production ready web server that is capable of serving directory listings in JSON format.

The approach is build on `caddy` being able to serve directory indexes as JSON when requested with the `Content-Type: application/json` header. This enables dynamic client-side rendering of a directory tree that can be used to navigate remote content.

The client-side can also accept static user provided `index.json` files which can be generated, for example, with the `tree` command line utility which can be filtered with `jq` as follows:

```bash
tree -L 1 -P '*.mp4|*.srt|*.vtt' --ignore-case -J -s | jq '.[0].contents' > index.json
```
The command above will only include MP4, SRT and VTT files. 

Adjust to your own needs or remove the entire `-P ...` part to include all files.

To browse a folder via your custom `index.json` file open the corresponding target folder with:

    http://example.com/path/to/project/mediabro24caddy/index.html#/path/to/data/folder/index.json
    
#### Advanced example: exclude files by glob, include by glob, include custom last modified date and size:
```bash
tree -I 'blood*|clotting*|Ohio*' -L 1 -P '*.mp3|*.flac|*.mp4|*.srt|*.vtt' --ignore-case -J -D --timefmt '%d-%b-%Y %H:%M' --dirsfirst -s | jq  '.[0].contents'
```

| flag                                      | description                        |
| ----------------------------------------- | ---------------------------------- |
| `-I "*ignored*"`                          | ignore file patterns               |
| `-L`                                      | one level deep                     |
| `-P "*.mp3\|*.flac\|*.mp4\|*.srt\|*.vtt"` | only include these file extensions |
| `-J`                                      | JSON output                        |
| `-s`                                      | include file size                  |
| `-D`                                      | include last modified date         |
| `--timefmt '%d-%b-%Y %H:%M'`              | set custom time format             |
| `--dirsfirst`                             | directories first                  |


##### Install `tree` and `jq` on MacOS:

```bash
brew install tree jq
```


##### Install `tree` and `jq` on Linux:
```bash
sudo apt install tree jq
```
