.DEFAULT_GOAL := build
build: build-html build-js

build-html:
	html-minifier-terser --remove-redundant-attributes \
	--remove-script-type-attributes --remove-style-link-type-attributes \
	--collapse-whitespace --collapse-boolean-attributes \
	--minify-css true --minify-js false --remove-comments \
	index.html -o index.min.html

build-js:
	terser js/main.js -o js/main.min.js

clean:
	rm -f -v index.min.html js/main.min.js
