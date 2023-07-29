.DEFAULT_GOAL := minify
minify: minify-html minify-js

minify-html:
	html-minifier-terser --remove-redundant-attributes \
	--remove-script-type-attributes --remove-style-link-type-attributes \
	--collapse-whitespace --collapse-boolean-attributes \
	--minify-css true --minify-js false --remove-comments \
	index.html -o index.min.html

minify-js:
	terser js/main.js -o js/main.min.js

install:
	npm install

clean:
	rm -f -v index.min.html js/main.min.js
