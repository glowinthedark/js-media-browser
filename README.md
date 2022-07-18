# MediaBrowser for Caddy

An HTML+JS media browser for navigating file systems that contain text files (supported formats are displayed with source code highlighting) images, audio or video files. For video/audio files associated content such as PDF, HTML, or TXT can be displayed based on file name matching rules.

The original use case is viewing audio or video files with associated notes in PDF, HTML or TXT format. Clicking a media file will open it in the media preview panel and search for a matching PDF or HTML file with the same base name. If a matching content file was found it will be loaded in the content preview panel below the media panel.

The app does not include a web server and works with the [caddy server](https://caddyserver.com/). 

An example `/etc/caddy/Caddyfile`:

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

* displaying PDF and HTML content with associated audio/video files
* adjustable playback speed for media files
* resizable navigation and content panels
* markdown rendering for `.md` files
* syntax highlighting for source code files

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

## Screenshot
![mediabrowser](https://raw.githubusercontent.com/glowinthedark/pymediacenter/master/mediabrowser-sample.png "sample screenshot")
