.PHONY: build test install clean

build:
	bashly generate

test:
	./test/libs/bats-core/bin/bats test/

install: build
	cp sgit /usr/local/bin/sgit
	chmod +x /usr/local/bin/sgit

clean:
	rm -f sgit
