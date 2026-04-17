.PHONY: build test install clean download

build:
	@command -v bashly >/dev/null 2>&1 || { echo "bashly not installed. Run: gem install bashly (or 'make download' to fetch the latest release binary)"; exit 1; }
	bashly generate

download:
	curl -sL https://github.com/mkuchak/sugar-git/releases/latest/download/sgit -o sgit
	chmod +x sgit

test: sgit
	./test/libs/bats-core/bin/bats test/

sgit:
	@$(MAKE) build || $(MAKE) download

install: build
	cp sgit /usr/local/bin/sgit
	chmod +x /usr/local/bin/sgit

clean:
	rm -f sgit
