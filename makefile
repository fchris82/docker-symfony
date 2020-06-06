VARS_OLD := $(.VARIABLES)
BIN_PATH := bin
CONFIG_PATH := config
DOCKER_TEMPLATE := Dockerfile.tmpl
# You have to define defaults to can compare in sed foreach!
TAG := symfony
PHP_VERSION := 7
CUSTOM_CONFIGS :=
XDEBUG_POSTFIX :=

define BUILD
	mkdir -p builds/$(TARGET_PATH)/config
	cp -R bin builds/$(TARGET_PATH)
	cp -R config/base/* builds/$(TARGET_PATH)/config
	$(foreach dir,$(CUSTOM_CONFIGS), cp -R config/$(dir)/* builds/$(TARGET_PATH)/config;)
	mv builds/$(TARGET_PATH)/config/Dockerfile.tmpl builds/$(TARGET_PATH)/Dockerfile
	sed $(foreach v, $(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), -e "s#{{ $(v) }}#$($(v))#") -i builds/$(TARGET_PATH)/Dockerfile
	cp config/makefile.tmpl builds/$(TARGET_PATH)/makefile
	sed $(foreach v, $(filter-out $(VARS_OLD) VARS_OLD,$(.VARIABLES)), -e "s#{{ $(v) }}#$($(v))#") -i builds/$(TARGET_PATH)/makefile
endef

.PHONY: all
all: base-php56 base-php70 base-php71 base-php72 base-php73 base-php74 ez1 ez2

.PHONY: build-all
build-all:
	find builds -type f -name makefile -execdir sh -c "make build-full" \;

.PHONY: base-php56
base-php56: TARGET_PATH := base/php5.6
base-php56: TAG := php5.6
base-php56: PHP_VERSION := 5.6
base-php56: CUSTOM_CONFIGS :=
base-php56: XDEBUG_POSTFIX := "-2.5.5"
base-php56:
	$(BUILD)

.PHONY: base-php70
base-php70: TARGET_PATH := base/php7.0
base-php70: TAG := php7.0
base-php70: PHP_VERSION := 7.0
base-php70: CUSTOM_CONFIGS :=
base-php70: XDEBUG_POSTFIX :=
base-php70:
	$(BUILD)

.PHONY: base-php71
base-php71: TARGET_PATH := base/php7.1
base-php71: TAG := php7.1
base-php71: PHP_VERSION := 7.1
base-php71: CUSTOM_CONFIGS :=
base-php71: XDEBUG_POSTFIX :=
base-php71:
	$(BUILD)

.PHONY: base-php72
base-php72: TARGET_PATH := base/php7.2
base-php72: TAG := php7.2
base-php72: PHP_VERSION := 7.2
base-php72: CUSTOM_CONFIGS := php7.2
base-php72: XDEBUG_POSTFIX :=
base-php72:
	$(BUILD)

.PHONY: base-php73
base-php73: TARGET_PATH := base/php7.3
base-php73: TAG := php7.3
base-php73: PHP_VERSION := 7.3
base-php73: CUSTOM_CONFIGS := php7.2
base-php73: XDEBUG_POSTFIX :=
base-php73:
	$(BUILD)

.PHONY: base-php74
base-php74: TARGET_PATH := base/php7.4
base-php74: TAG := php7.4
base-php74: PHP_VERSION := 7.4
base-php74: CUSTOM_CONFIGS := php7.2
base-php74: XDEBUG_POSTFIX :=
base-php74:
	$(BUILD)

.PHONY: ez1
ez1: TARGET_PATH := ez/1
ez1: TAG := ez1
ez1: PHP_VERSION := 7.1
ez1: CUSTOM_CONFIGS := ez
ez1: XDEBUG_POSTFIX :=
ez1:
	$(BUILD)

.PHONY: ez2
ez2: TARGET_PATH := ez/2
ez2: TAG := ez2
ez2: PHP_VERSION := 7.2
ez2: CUSTOM_CONFIGS := php7.2 ez
ez2: XDEBUG_POSTFIX :=
ez2:
	$(BUILD)
