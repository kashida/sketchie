SORTJS=ir2js --stdout --sort

CLIENT_PKG=compiled/client/packages.js
SERVER_PKG=compiled/server/packages.js

CLIENT_IR=$(wildcard client/*.ir) $(wildcard client/*/*.ir)
CLIENT_JS=$(patsubst %.ir,%.js,$(subst client,compiled/client,$(CLIENT_IR)))
TESTS_IR=$(filter-out test/_%,$(wildcard test/*.ir))
TESTS_JS=$(patsubst %.ir,%.js,$(subst test,compiled/test,$(TESTS_IR)))
SERVER_IR=$(wildcard server/*.ir)
SERVER_JS=$(patsubst %.ir,%.js,$(subst server,compiled/server,$(SERVER_IR)))

CLOSURE_ARGS=
CLOSURE_ARGS+=-jar closure/compiler.jar
CLOSURE_ARGS+=--externs ~/ir2js/misc/externs.js
CLOSURE_ARGS+=--externs server/externs.js
CLOSURE_ARGS+=--formatting PRETTY_PRINT
CLOSURE_ARGS+=--compilation_level ADVANCED_OPTIMIZATIONS
CLOSURE_ARGS+=--summary_detail_level 3
CLOSURE_ARGS+=--warning_level VERBOSE
CLOSURE_ARGS+=--jscomp_error=accessControls
CLOSURE_ARGS+=--jscomp_error=ambiguousFunctionDecl
CLOSURE_ARGS+=--jscomp_error=checkRegExp
CLOSURE_ARGS+=--jscomp_error=checkTypes
CLOSURE_ARGS+=--jscomp_error=checkVars
CLOSURE_ARGS+=--jscomp_error=const
CLOSURE_ARGS+=--jscomp_error=constantProperty
CLOSURE_ARGS+=--jscomp_error=deprecated
CLOSURE_ARGS+=--jscomp_error=duplicateMessage
CLOSURE_ARGS+=--jscomp_error=es5Strict
CLOSURE_ARGS+=--jscomp_error=externsValidation
CLOSURE_ARGS+=--jscomp_error=fileoverviewTags
CLOSURE_ARGS+=--jscomp_error=globalThis
CLOSURE_ARGS+=--jscomp_error=internetExplorerChecks
CLOSURE_ARGS+=--jscomp_error=invalidCasts
CLOSURE_ARGS+=--jscomp_error=missingProperties
CLOSURE_ARGS+=--jscomp_error=nonStandardJsDocs
CLOSURE_ARGS+=--jscomp_error=strictModuleDepCheck
CLOSURE_ARGS+=--jscomp_error=typeInvalidation
CLOSURE_ARGS+=--jscomp_error=undefinedNames
CLOSURE_ARGS+=--jscomp_error=undefinedVars
CLOSURE_ARGS+=--jscomp_error=unknownDefines
CLOSURE_ARGS+=--jscomp_error=uselessCode
CLOSURE_ARGS+=--jscomp_error=visibility


default: client


############################################################
# Basic rules.

compiled/client/%.js: client/%.ir
	@mkdir -p `dirname $@`
	@ir2js --basedir=client --outdir=compiled/client $^

compiled/test/%.js: test/%.ir
	@mkdir -p `dirname $@`
	@ir2js --basedir=test --outdir=compiled/test $^

compiled/server/%.js: server/%.ir
	@mkdir -p `dirname $@`
	@ir2js --basedir=server --outdir=compiled/server $^

$(CLIENT_PKG):
	@mkdir -p `dirname $@`
	@ir2js --pkglist --basedir=client $(CLIENT_IR) > $@

$(SERVER_PKG):
	@mkdir -p `dirname $@`
	@ir2js --pkglist --basedir=server $(SERVER_IR) > $@


############################################################
# Main targets.

client: compiled/_scrawler.js
server: compiled/server.js

sort:
	@echo "$(shell $(SORTJS) $(CLIENT_JS))"

compiled/_scrawler.js: $(CLIENT_JS) $(CLIENT_PKG)
	@echo '===== VERIFY client: compiling'
	java $(CLOSURE_ARGS) --js_output_file $@ --js $(CLIENT_PKG) \
	$(addprefix --js ,$(shell $(SORTJS) $(CLIENT_JS))) || \
	rm $@

run: compiled/server.js
	node $^

compiled/server.js: compiled/_server.js
	@echo '===== MERGE server'
	ir2js --merge --basedir=compiled --outfile=$@ $(SERVER_JS)

compiled/_server.js: $(SERVER_JS) $(SERVER_PKG)
	@echo '===== VERIFY server: compiling'
	java $(CLOSURE_ARGS) --js_output_file $@ --js $(SERVER_PKG) \
	$(addprefix --js ,$(shell $(SORTJS) $(SERVER_JS))) || \
	rm $@

tests: compiled/_tests.js
	chromium-browser 'localhost:1357/_t.html?test=text'
	chromium-browser 'localhost:1357/_t.html?test=draw'
	rm -f data/_save_test.html
	chromium-browser 'localhost:1357/_t.html?test=save'

# TODO: Compile the test files too.
# They use the same class name (Test), so they conflict if all compiled into
# one js. Either use different class names or compile them into separate js
# files.
compiled/_tests.js: $(CLIENT_JS) $(TESTS_JS) $(CLIENT_PKG)
	@echo '===== VERIFY tests: compiling'
	java $(CLOSURE_ARGS) --js_output_file $@ --js $(CLIENT_PKG) \
	$(addprefix --js ,$(shell $(SORTJS) $(CLIENT_JS) $(TESTS_JS))) || \
	rm $@

# TODO: Make the rest work for Chrome Extension.
chrome/background.js: server/background.coffee
	coffee -j $@ -c $^

chrome/femto.js: $(CLIENT_JS)
	coffee -j $@ -c $^

ext: chrome/femto.js chrome/background.js

############################################################
# Non-build commands.

clean:
	rm -rf compiled

cclean:
	rm -rf compiled/client
