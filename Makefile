txt:
	$(MAKE) -C rfcs txt

xml:
	$(MAKE) -C rfcs xml

html:
	$(MAKE) -C rfcs html w

#html_body:
#	$(MAKE) -C rfcs html_body

clean:
	$(MAKE) -C rfcs clean

rsync: clean html
	rsync -avz rfcs/index.html OpenEdX4:'/var/www/static/cdd-rfc-web' --exclude '.git' --rsync-path='sudo rsync'
# OpenEdX is a HostName in my ~/.ssh/config, adding this to a `ls rfcs/*.md | entr make rsync` speeds up dev/deploy lifecycle
