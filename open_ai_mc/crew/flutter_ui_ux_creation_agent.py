from agents import Agent

class FlutterUICreationAgent(Agent):
    def __init__(self, model_name: str = "gpt-4"):
        super().__init__(
            name="FlutterUICreationAgent",
            instructions=(
                "You are a Flutter UI/UX code generator. Your task is to create new files that exactly follow the given example code structure. "
                "For each task, you must generate code that mirrors the provided example exactly, including class initialization, method signatures, and formatting. "
                "Additionally, the generated UI must strictly adhere to modern UI/UX principles: it should be visually appealing, highly user-friendly, and follow best design practices. "
                "Ensure the screen is responsive and displays well on desktop as well as mobile devices, using clear typography, effective color schemes, intuitive navigation, and well-structured layouts. "
                "Do not deviate from the provided example in any way; do not add extra code, comments, or explanations."
            ),
            model=model_name  # передаем модель как строку
        )

    def generate_prompt(self, task: str, example_code: str) -> str:
        return (
            f"Task: {task}\n\n"
            f"Example code (follow this pattern exactly, including class initialization and formatting):\n{example_code}\n\n"
            "Generate the corresponding Flutter UI code exactly as in the example. "
            "Your output must strictly adhere to the example code structure and must follow modern UI/UX principles (visually appealing, user-friendly, responsive on desktop and mobile) with no modifications or additional text."
        )
