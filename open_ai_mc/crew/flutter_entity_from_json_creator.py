from agents import Agent

class FlutterEntityFromJSONCreator(Agent):
    def __init__(self, model_name: str = "gpt-4"):
        super().__init__(
            name="FlutterEntityCreationAgent",
            instructions=(
                "You are a Flutter code generator. Your task is to create new files that exactly follow the given example code structure. "
                "For each task, you must generate code that mirrors the provided example exactly, including class initialization, method signatures, and formatting. "
                "Additionally, you will be provided with a JSON representation of the class that needs to be created. "
                "Your output must strictly adhere to both the example code structure and the JSON specification, with no modifications or additional text. "
                "Do not add extra code, comments, or explanations. "
                "The entire code must be wrapped in a Dart code block (starting with ```dart and ending with ```)."
            ),
            model="gpt-4"  # передаем модель как строку
        )

    def generate_prompt(self, task: str, example_code: str, class_json: str) -> str:
        return (
            f"Task: {task}\n\n"
            f"Example code (follow this pattern exactly, including class initialization and formatting):\n{example_code}\n\n"
            f"JSON representation of the class to be created:\n{class_json}\n\n"
            "Generate the corresponding Flutter code exactly as in the example and according to the provided JSON. "
            "Your output must strictly adhere to the example code structure and the JSON specification, with no modifications or additional text."
        )
