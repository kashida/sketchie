NODE=nodejs
IR2JS=NODE_PATH=~/ir2js/saved $(NODE) ~/ir2js/saved/convert.js
SORTJS=$(IR2JS) --stdout --sort

CLIENT_PKG=compiled/client/packages.js
SERVER_PKG=compiled/server/packages.js

CLIENT_IR=$(wildcard client/*.ir) $(wildcard client/*/*.ir)
CLIENT_JS=$(patsubst %.ir,%.js,$(subst client,compiled/client,$(CLIENT_IR)))
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


default: serve
client: compiled/_scrawler.js


############################################################
# Basic rules.

compiled/client/%.js: client/%.ir
	@mkdir -p `dirname $@`
	@$(IR2JS) --basedir=client --outdir=compiled/client $^

compiled/server/%.js: server/%.ir
	@mkdir -p `dirname $@`
	@$(IR2JS) --basedir=server --outdir=compiled/server $^

$(CLIENT_PKG):
	@mkdir -p `dirname $@`
	@$(IR2JS) --pkglist --basedir=client $(CLIENT_IR) > $@

$(SERVER_PKG):
	@mkdir -p `dirname $@`
	@$(IR2JS) --pkglist --basedir=server $(SERVER_IR) > $@


############################################################
# Main targets.

sort:
	@echo "$(shell $(SORTJS) $(CLIENT_JS))"

compiled/_scrawler.js: $(CLIENT_JS) $(CLIENT_PKG)
	@echo '===== VERIFY client: compiling'
	java $(CLOSURE_ARGS) --js_output_file $@ --js $(CLIENT_PKG) \
	$(addprefix --js ,$(shell $(SORTJS) $(CLIENT_JS))) || \
  rm $@

serve: compiled/server.js
	NODE_PATH=~/ir2js/saved $(NODE) $^

compiled/server.js: compiled/_server.js
	@echo '===== MERGE server'
	$(IR2JS) --merge --basedir=compiled --outfile=$@ $(SERVER_JS)

compiled/_server.js: $(SERVER_JS) $(SERVER_PKG)
	@echo '===== VERIFY server: compiling'
	java $(CLOSURE_ARGS) --js_output_file $@ --js $(SERVER_PKG) \
	$(addprefix --js ,$(shell $(SORTJS) $(SERVER_JS))) || \
  rm $@

# TODO: make the rest work.
chrome/background.js: server/background.coffee
	coffee -j $@ -c $^

chrome/femto.js: $(CLIENT_JS)
	coffee -j $@ -c $^

ext: chrome/femto.js chrome/background.js


############################################################
# Non-build commands.

clean:
	rm -rf compiled
