MMARK :=mmark
TWO := ""
TXT := $(patsubst %.md,%.txt,$(wildcard *.md))
HTML := $(patsubst %.md,%.html,$(wildcard *.md))
XML := $(patsubst %.md,%.xml,$(wildcard *.md))

txt: $(TXT)
html: $(HTML)

%.txt: %.md
	$(MMARK) $< > $(basename $<).xml;
	if [ -z $(TWO) ]; then \
	    xml2rfc -v --text --v3 $(basename $<).xml -o $(basename $<).txt && rm $(basename $<).xml; \
	else \
	    xml2rfc -v --text $(basename $<).xml -o $(basename $<).txt && rm $(basename $<).xml; \
	fi

%.html: %.md
	$(MMARK) $< > $(basename $<).xml;
	if [ -z $(TWO) ]; then \
		xml2rfc -v --html --v3 $(basename $<).xml -o $(basename $<).html && rm $(basename $<).xml; \
	else \
		xml2rfc -v --html $(basename $<).xml -o $(basename $<).html && rm $(basename $<).xml; \
	fi

xml: $(XML)

%.xml: %.md
	if [ -z $(TWO) ]; then \
	    $(MMARK) -bibliography=false $< > $(basename $<).xml; \
	else \
	    $(MMARK) -bibliography=false -2 $< > $(basename $<).xml; \
	fi

.PHONY: clean html_body
clean:
	rm -fv *.txt *.xml *.html

# html_body: $(HTML)
# 	$(eval TMPFILE := $(shell mktemp))
# 	@for h in $(HTML); do \
# 		hxnormalize -xe "$$h" | hxselect -cis '\n' 'body' | hxremove -i 'script' | hxremove 'address' | node -e 'process.stdin.resume(); process.stdin.setEncoding("utf8"); process.stdin.on("data", d => process.stdout.write(d.replace(/(&nbsp;|<a([^>]+\/)>)/ig, "")));' > $(TMPFILE); \
# 		mv $(TMPFILE) "$$h" ; \
# 		echo html bodied "$$h" ;\
# 	done
