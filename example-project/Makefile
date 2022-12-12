build:
	docker build -t $(TAG) .

lambda-local:
	./batect lambda-local

test-lint:
	./batect test-lint

test-integration:
	./batect test-integration

test-unit:
	./batect test-unit

fix-lint:
	./batect fix-lint

.PHONY: test
test: test-integration test-unit
