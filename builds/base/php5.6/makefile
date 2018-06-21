.PHONY: build
build:
	docker build --no-cache --tag fchris82/symfony:php5.6 .

.PHONY: push
push:
	docker push fchris82/symfony:php5.6

.PHONY: build-full
build-full: build push

.PHONY: enter
enter:
	docker run -it fchris82/symfony:php5.6 /bin/bash
