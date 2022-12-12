from typing import Dict

from aws_lambda_powertools.utilities.typing import LambdaContext

from example import logger


@logger.inject_lambda_context(log_event=True)
def handle(event: Dict, context: LambdaContext) -> Dict:
    print(event)

    return {"hello": "world"}
