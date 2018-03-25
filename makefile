VARS_OLD := $(.VARIABLES)
BIN_PATH := bin
CONFIG_PATH := config
DOCKER_TEMPLATE := Dockerfile.tmpl
# You have to define defaults to can compare in sed foreach!
TAG := symfony
PHP_VERSION := 7

define BUILD
	mkdir -p builds/$(TARGET_PATH)
	cp -R bin builds/$(TARGET_PATH)
	cp -R config builds/$(TARGET_PATH)
	cp $(DOCKER_TEMPLATE) builds/$(TARGET_PATH)/Dockerfile
	sed $(foreach v, $(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), -e "s#{{ $(v) }}#$($(v))#") -i builds/$(TARGET_PATH)/Dockerfile
endef

.PHONY: all
all: base-php70 base-php71 base-php72 ez1 ez2

.PHONY: base-php70
base-php70: TARGET_PATH := base/php7.0
base-php70: TAG := symfony-php7.0
base-php70: PHP_VERSION := 7.0
base-php70:
	$(BUILD)

.PHONY: base-php71
base-php71: TARGET_PATH := base/php7.1
base-php71: TAG := symfony-php7.1
base-php71: PHP_VERSION := 7.1
base-php71:
	$(BUILD)

.PHONY: base-php72
base-php72: TARGET_PATH := base/php7.2
base-php72: TAG := symfony-php7.2
base-php72: PHP_VERSION := 7.2
base-php72:
	$(BUILD)

.PHONY: ez1
ez1: TARGET_PATH := ez/1
ez1: TAG := ez1
ez1: PHP_VERSION := 7.1
ez1:
	$(BUILD)

.PHONY: ez2
ez2: TARGET_PATH := ez/2
ez2: TAG := ez2
ez2: PHP_VERSION := 7.2
ez2:
	$(BUILD)
