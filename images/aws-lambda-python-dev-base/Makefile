CODE_PATH ?= $(LAMBDA_TASK_ROOT)
CONFIG_PATH = /devtools/pyproject.toml

bandit:
	@echo "Running bandit"
	poetry run bandit -c $(CONFIG_PATH) -r $(CODE_PATH)

black:
	@echo "Running black"
	poetry run black --config $(CONFIG_PATH) --check --diff $(CODE_PATH)

mypy:
	@echo "Running mypy"
	poetry run mypy --install-types --config-file $(CONFIG_PATH) $(CODE_PATH)

isort:
	@echo "Running isort"
	poetry run isort --sp $(CONFIG_PATH) --check --diff $(CODE_PATH)

trivy-code:
	@echo "Running trivy on the code"
	trivy fs $(CODE_PATH)

.PHONY: lint
lint: bandit black mypy isort trivy-code
	@echo "Completed linting"
