# MediaBrowser for Caddy

An HTML+JS media browser for navigating file systems that contain text files, images, audio or video files. For video/audio files associated content such as PDF, HTML, or TXT can be displayed based on file name matching rules.

The intended use is HTTP browsing of audio or video files with associated notes in PDF, HTML, Markdown, or plain text format. Clicking a media file will open it in the media preview panel and search for a matching PDF, HTML, etc file with the same base name. If a matching content file was found it will be loaded in the content preview panel below the media panel.

The app does not include a web server and works OOTB with the [caddy server](https://caddyserver.com/). The entire code runs client-side in the web browser. 

<sup>The media browser can also be used with other HTTP servers but in that case an static `index.json` file must be provided in the folders to be browsed. For details see the [Implementation](#implementation) section below. </sup>

An example `/etc/caddy/Caddyfile` for caddy server:

```
http:// {

	root * /media

	file_server browse {
		root /media
		hide .git
		index ''
	}
}
```

> NOTE: The caddy `file_server_browser` module must have the `index ''` instruction. Otherwise caddy will attempt to load any existing `index.html` files (if present) instead of returning directory listings in JSON format as required by the client-side.

#### Features:

* displaying PDF, HTML, Markdown content with associated audio/video files
* adjustable playback speed for media files
* resizable navigation and content panels
* markdown rendering for `.md` files
* syntax highlighting for source code files
* automatic detection and loading of WebVTT subtitles for video files

Example: if a folder contains a PDF file named `lesson-01.pdf` and a video file named `lesson-01.mp4`, then clicking the PDF file will display it in the content panel while the video will start playing in the media panel above.

## Supported media formats
Playback of media files is handled by the web browser therefore support is limited to the capabilities of the corresponding HTML5 `<audio/>` and `<video/>` elements which currently include: MP3, MP4 audio/video (H.264, AAC, MP3 codecs), MP4 container with Flac codec, OGG audio and video (Theora, Vorbis, Opus, Flac codecs), FLAC, WebM audio/video (VP8, VP9 codecs), WAV (PCM). Limited support for Matroska (MKV) is present for browsers that support it. 

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

# Implementation

The approach is build on `caddy` being able to serve directory indexes as JSON when requested with the `Content-Type: application/json` header. This enables dynamic client-side rendering of a directory tree that can be used to navigate remote content.

The client-side can also accept static user provided `index.json` which can be generated, for example, the output of the `tree` command line utility which can be filtered with `jq` as follows:

```bash
tree -L 1 -P '*.mp4|*.srt|*.vtt' --ignore-case -J -s | jq '.[0].contents' > index.json
```
The command above will only include MP4, SRT and VTT files. 

Adjust to your own needs or remove the entire `-P ...` part to include all files.

#### Advanced example: exclude files by glob, include by glob, include custom last modified date and size:
```bash
tree -I 'blood*|clotting*|Ohio*' -L 1 -P '*.mp3|*.flac|*.mp4|*.srt|*.vtt' --ignore-case -J -D --timefmt '%d-%b-%Y %H:%M' --dirsfirst -s | jq  '.[0].contents'
```

`-I` = ignore file patterns
`-L ` = one level deep
`-P '*.mp3|*.flac|*.mp4|*.srt|*.vtt'` = only include these file extensions
`-J` = JSON output
`-s` = include file size
`-D` = include last modified date
` --timefmt '%d-%b-%Y %H:%M'` = set custom time format
`--dirsfirst` = directories first


##### Install `tree` and `jq` on MacOS:

```bash
brew install tree jq
```


##### Install `tree` and `jq` on Linux:
```bash
sudo apt install tree jq
```
