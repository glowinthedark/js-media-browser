# MediaBrowser for Caddy

MediaBrowser for Caddy is a minimalistic web client that provides an easy way to browse files on a computer, and view videos, audios, PDFs, images and text content. The only server-side requirement is a vanilla [caddy server](https://caddyserver.com/) installation.

MediaBrowser does not aim to replace [Plex](https://www.plex.tv/), [Jellyfin](https://jellyfin.org/), [Dim](https://github.com/Dusk-Labs/dim), [Filebrowser](https://github.com/filebrowser/filebrowser).

The intended use is HTTP browsing of audio or video files with associated notes in PDF, HTML, Markdown, or plain text. Clicking a media file will open it in the media preview panel and attempt to find a matching PDF, HTML, etc file with the same base name. If matching content was found it will be loaded in the content preview panel below the media panel. You can also add your own matching rules by editing the code. 

MediaBrowser is a purely client-side web client that works together with [caddy server](https://caddyserver.com/).  

<sup>MediaBrowser can also work with other HTTP servers. In this scenario a static `index.json` file must be present in each folder that is exposed for browsing. For details on how to generate static index files see the [Using with other web servers](#using-with-other-web-servers) section below. </sup>

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

> NOTE: The caddy `file_server_browser` module must have the `index ''` instruction, or otherwise caddy will attempt to load existing `index.html` files (if present) instead of returning directory listings in JSON format as required by the client-side.

## Features:

* displaying PDF, HTML, Markdown content with associated audio/video files
* adjustable playback speed for media files
* resizable navigation and content panels
* markdown rendering for `.md` files
* syntax highlighting for source code files
* automatic detection and loading of WebVTT subtitles for video files

Example: if a folder contains an MP4 file named `video-01.mp4` and a PDF file named `video-01.pdf`, then clicking the MP4 file will start playing in the media panel above while the PDF will be loaded in the content panel below the video . 

Additionally, if `video-01.en.vtt`, `video-01.es.vtt` etc are present in the same folder then subtitles will be picked up and can be selected enabled from the subtitles submenu in the video controls.

## Supported media formats
Playback of media files is limited by the capabilities of the corresponding HTML5 `<audio/>` and `<video/>` elements which currently include: MP3, MP4 audio/video (H.264, AAC, MP3 codecs), MP4 container with Flac codec, AAC, OGG audio and video (Theora, Vorbis, Opus, Flac codecs), FLAC, WebM audio/video (VP8, VP9 codecs), WAV (PCM). Limited support for Matroska (MKV) is present for browsers that support it. 

For more details see the [mozilla browser media compatibility table](https://developer.mozilla.org/en-US/docs/Web/Media/Formats/Video_codecs#common_codecs).

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

The URL can process the following extra parameters:

| Param  | Description |
| ------------- | ------------- |
| **`hidden=true`**  | include files starting with a dot, e.g. `.vimrc`  |
| **`skip=12`**  | skip the first NN seconds  |
| **`pdfjs=true`**  | force PDF rendering with pdf.js instead of native PDF renderer  |
| **`filter=\.(html\|pdf\|jpg)`** | regex to only include files that match the expression, e.g. html, pdf and jpg |
| **`nohl=1`**  | disable syntax highlighting for all text files (e.g. useful for large files) |

> `true`, `1`, `yes`, `on` all have the same effect

Example URL with custom parameters which shows dot files, uses pdf.js for PDF rendering and skips the first 15 seconds on media playback: 


- `http://example.com/path/to/project/mediabro24caddy/index.html?hidden=true&skip=15&pdfjs=true#/path/to/content/`

## How does it work?

[Caddy](https://caddyserver.com/) is a fast, lightweight and production ready web server. The approach is build on `caddy`'s `file-server` plugin capability to serve directory indexes as JSON when requested with the `Content-Type: application/json` header. This makes possible dynamic client-side rendering of a directory tree that can be used to navigate remote content via ajax HTTP requests.

## Using with other web servers

Usage with another web server requires that each folder to browse contains an `index.json` file with directory contents. The files can be generated, for example, with the `tree` command line utility as follows:

```bash
tree -L 1 -P '*.mp4|*.srt|*.vtt' --ignore-case -J -s -o index.json
```
> The command above will only include MP4, SRT and VTT files. Adjust to your own needs or remove the entire `-P ...` part to include all files.

You can generate `index.json` files recursively in an entire subtree with `find`. This invocation will create the `index.json` recursively excluding from the listing the actual `index.json` itself and the `.git` folder):

```bash
find . -type d ! -path "*/.git/*" -exec sh -c 'echo "$0" && tree "$0" -L 1 -I "index.json" --ignore-case -J -s -D -o "$0/index.json"' {} \;
```

To browse a folder via a custom `index.json` file open the corresponding target folder with:

    http://example.com/path/to/project/mediabro24caddy/index.html#/path/to/data/folder/index.json
    
#### Example 2: exclude files by glob, include by glob, include custom last modified date and size:
```bash
tree -I '*.bak|*.pyc|index.json' -L 1 -P '*.mp3|*.flac|*.mp4|*.srt|*.vtt' --ignore-case -J -D --timefmt '%d-%b-%Y %H:%M' --dirsfirst -s -o index.json
```

where:

| flag                                      | description                        |
| ----------------------------------------- | ---------------------------------- |
| `-I '*.bak\|*.pyc\|index.json'`           | ignore file patterns               |
| `-L 1`                                    | one level deep                     |
| `-P "*.mp3\|*.flac\|*.mp4\|*.srt\|*.vtt"` | only include these file extensions |
| `-J`                                      | JSON output                        |
| `-s`                                      | include file size                  |
| `-D`                                      | include last modified date         |
| `--timefmt '%d-%b-%Y %H:%M'`              | set custom time format             |
| `--dirsfirst`                             | directories first                  |


##### Install `tree` on MacOS:

```bash
brew install tree
```

##### Install `tree` on Linux:
```bash
sudo apt install tree
```

##### Install `tree` on Windows

- https://gnuwin32.sourceforge.net/packages/tree.htm
