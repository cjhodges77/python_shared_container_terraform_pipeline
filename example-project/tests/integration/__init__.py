import os

LAMBDA_ENDPOINT = "localhost" if os.getenv("LAMBDA_TASK_ROOT") is None else "lambda"
