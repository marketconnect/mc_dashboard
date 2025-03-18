from agents import Agent

class FlutterCreationAgent(Agent):
    def __init__(self, model_name: str = "gpt-4"):
        super().__init__(
            name="FlutterCreationAgent",
            instructions=(
                "You are a Flutter code generator. Your task is to create new files that exactly follow the given example code structure. "
                "For each task, you must generate code that mirrors the provided example exactly, including class initialization, method signatures, and formatting. "
                "Do not deviate from the example in any way; do not add extra code, comments, or explanations."
            ),
            model=model_name  # передаем модель как строку
        )

    def generate_prompt(self, task: str, example_code: str) -> str:
        return (
            f"Task: {task}\n\n"
            f"Example code (follow this pattern exactly, including class initialization and formatting):\n{example_code}\n\n"
            "Generate the corresponding Flutter code exactly as in the example. Your output must strictly adhere to the example code structure, with no modifications or additional text."
        )
