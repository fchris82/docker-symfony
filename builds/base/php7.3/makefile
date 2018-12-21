.PHONY: build
build:
	docker build --no-cache --pull --tag fchris82/symfony:php7.3 .

.PHONY: push
push:
	docker push fchris82/symfony:php7.3

.PHONY: build-full
build-full: build push

.PHONY: enter
enter:
	docker run -it fchris82/symfony:php7.3 /bin/bash
