.PHONY: build install clean

build:
	bashly generate

install: build
	cp sgit /usr/local/bin/sgit
	chmod +x /usr/local/bin/sgit

clean:
	rm -f sgit
