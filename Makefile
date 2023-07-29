.DEFAULT_GOAL := minify
minify:     # minify html+js (default)
	npm run build

install:    # install npm dependencies for minification
	npm install

clean:      # remove generated files
	rm -f -v index.min.html js/main.min.js

help:       # show available targets
	@grep '^[[:alnum:]]\+:' Makefile
