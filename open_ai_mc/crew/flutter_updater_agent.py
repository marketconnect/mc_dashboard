from agents import Agent


class FlutterUpdaterAgent(Agent):
    def __init__(self, model_name: str = "gpt-4"):
        super().__init__(
            name="FlutterUpdaterAgent",
            instructions=(
                "You are a Flutter code updater specialized in modifying existing files. "
                "When given file content and update instructions, add the necessary lines without altering the rest of the code. "
                "Do not output any extra text."
            ),
            model=model_name  # передаем модель как строку
        )

    def generate_prompt(self, update_instructions: str, file_content: str) -> str:
        return (
            f"Update instructions: {update_instructions}\n\n"
            f"Current file content:\n{file_content}\n\n"
            "Update the file content accordingly by adding the necessary lines, without modifying the rest of the code."
        )
