
html:
	ruby mak/make_html.rb

serve:
	ruby -run -ehttpd www/ -p7008
s: serve


.PHONY: serve html

