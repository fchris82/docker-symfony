.PHONY: build
build:
	docker build --no-cache --pull --tag fchris82/symfony:php7.4 .

.PHONY: push
push:
	docker push fchris82/symfony:php7.4

.PHONY: build-full
build-full: build push

.PHONY: enter
enter:
	docker run -it fchris82/symfony:php7.4 /bin/bash
