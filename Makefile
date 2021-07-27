ALL	= 

objs	= 

.SUFFIXES:	.so .o .c .f

#.o.so:
#	${LD} ${LFLAGS} -o $@ $< ${LINK_LIB}

all: ${ALL}


.PHONY: clean test doc
clean:
	$(RM) bin/*~

## You may need RUBYLIB=`pwd`/lib:$RUBYLIB
test:
	ruby lib/japanese_utils.rb
#	rake test

## yard2md_afterclean in Gem plain_text https://rubygems.org/gems/plain_text
doc:
	yard doc
#	yard doc; [[ -x ".github" && ( "README.en.rdoc" -nt ".github/README.md" ) ]] && ( ruby -r rdoc -e 'puts RDoc::Markup::ToMarkdown.new.convert ARGF.read' < README.en.rdoc | yard2md_afterclean > .github/README.md.$$ && ( mv -f .github/README.md.$$ .github/README.md && echo ".github/README.md is updated." ) || ( echo "ERROR: failed to create .github/README.md" >&2 ) ) || exit 0

