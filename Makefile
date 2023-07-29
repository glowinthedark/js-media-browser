.DEFAULT_GOAL := minify
minify: minify-html minify-js     # minify html+js (default)

minify-html:   # minify HTML
	html-minifier-terser --remove-redundant-attributes \
	--remove-script-type-attributes --remove-style-link-type-attributes \
	--collapse-whitespace --collapse-boolean-attributes \
	--minify-css true --minify-js false --remove-comments \
	index.html -o index.min.html

minify-js:     # minify js
	terser js/main.js -o js/main.min.js

install:       # install npm dependencies for minification
	npm install

clean:         # remove generated files
	rm -f -v index.min.html js/main.min.js

help:          # show available targets
	@grep '^[[:alnum:]]\+:' Makefile
