# This file is licensed under the Affero General Public License version 3 or
# later. See the COPYING file.

app_name=$(notdir $(CURDIR))
project_directory=$(CURDIR)/../$(app_name)
build_tools_directory=$(CURDIR)/build/tools
source_build_directory=$(CURDIR)/build/artifacts/source
source_package_name=$(source_build_directory)/$(app_name)
appstore_build_directory=$(CURDIR)/build/artifacts
appstore_package_name=$(appstore_build_directory)/$(app_name)

all: dev-setup lint build-js-production install-composer-deps-dev test-php

# Dev env management
dev-setup: clean clean-dev install-npm-deps-dev

npm-update:
	npm update

composer.phar:
	curl -sS https://getcomposer.org/installer | php

install-deps: install-composer-deps-dev install-npm-deps-dev

install-npm-deps-dev:
	npm ci

install-composer-deps: composer.phar
	php composer.phar install --no-dev -o

install-composer-deps-dev: composer.phar
	php composer.phar install -o

# Building
build-js:
	npm run dev

build-js-production:
	npm run build

watch-js:
	npm run watch

# Testing
test:
	npm run test

test-watch:
	npm run test:watch

test-coverage:
	npm run test:coverage

test-php:
	php composer.phar run test:unit
	php composer.phar run test:integration

test-php-coverage:
	php composer.phar run test:unit -- --coverage-clover=coverage-unit.xml
	php composer.phar run test:integration -- --coverage-clover=coverage-integration.xml

# Linting
lint:
	npm run lint

lint-fix:
	npm run lint:fix

# Style linting
stylelint:
	npm run stylelint

stylelint-fix:
	npm run stylelint:fix

# Cleaning
clean:
	rm -rf js

clean-dev:
	rm -rf node_modules
	rm -rf vendor

# Builds the source package for the app store, ignores php and js tests
appstore:
	rm -rf $(appstore_build_directory)
	mkdir -p $(appstore_build_directory)
	tar czf $(appstore_package_name).tar.gz \
	--exclude-vcs \
	$(project_directory)/appinfo \
	$(project_directory)/css \
	$(project_directory)/img \
	$(project_directory)/l10n \
	$(project_directory)/lib \
	$(project_directory)/templates \
	$(project_directory)/js \
	$(project_directory)/COPYING \
	$(project_directory)/CHANGELOG.md

assemble:
	rm -rf $(appstore_build_directory)
	mkdir -p $(appstore_build_directory)
	rsync -a \
	--exclude=babel.config.js \
	--exclude=build \
	--exclude=composer.json \
	--exclude=composer.lock \
	--exclude=docs \
	--exclude=.drone.yml \
	--exclude=tsconfig.json \
	--exclude=phpunit.xml \
	--exclude=.eslintignore \
	--exclude=.eslintrc.js \
	--exclude=.git \
	--exclude=.gitattributes \
	--exclude=.github \
	--exclude=.gitignore \
	--exclude=.l10nignore \
	--exclude=mkdocs.yml \
	--exclude=Makefile \
	--exclude=node_modules \
	--exclude=package.json \
	--exclude=package-lock.json \
	--exclude=.php_cs.dist \
	--exclude=.php_cs.cache \
	--exclude=psalm.xml \
	--exclude=README.md \
	--exclude=src \
	--exclude=.stylelintignore \
	--exclude=stylelint.config.js \
	--exclude=.tx \
	--exclude=tests \
	--exclude=vendor \
	--exclude=webpack.js \
	--exclude=webpack.config.js \
	$(project_directory) $(appstore_build_directory)
	tar -czf $(appstore_build_directory)/$(app_name).tar.gz \
		-C $(appstore_build_directory) $(app_name)
