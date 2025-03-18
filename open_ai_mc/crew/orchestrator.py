import os
from crew.flutter_creation_agent import FlutterCreationAgent
from crew.flutter_updater_agent import FlutterUpdaterAgent
from crew.flutter_ui_ux_creation_agent import FlutterUICreationAgent
from crew.flutter_entity_from_json_creator import FlutterEntityFromJSONCreator
from agents import Runner

class FlutterTaskOrchestrator:
    def __init__(self, read_file_content):
        """
        read_file_content: функция для чтения содержимого файла,
        принимает путь к файлу и возвращает его содержимое.
        """
        self.creation_agent = FlutterCreationAgent(model_name="gpt-4o-mini")
        self.updater_agent = FlutterUpdaterAgent(model_name="gpt-4o-mini")
        self.ui_creation_agent = FlutterUICreationAgent(model_name="gpt-4o-mini")
        self.entity_from_json_creation_agent = FlutterEntityFromJSONCreator(model_name="gpt-4o-mini")
        self.read_file_content = read_file_content

    async def handle_task(self, task_type: str, task_description: str, sample_file_path: str = None, new_file_name: str = None, class_json: str = None) -> str:
        """
        task_type: "apiclient", "service", "viewmodel", "screen", "integration", "entity", "entity from JSON", "question".
        task_description: описание задачи.
        sample_file_path:
            - Для задач создания: путь к файлу-образцу (его стиль используется как шаблон).
            - Для интеграционных задач: путь к существующему файлу, который нужно обновить.
        new_file_name:
            - Для задач создания: имя нового файла, который будет создан в той же директории, что и sample_file_path.
        class_json:
            - Для типа "entity from JSON": JSON-представление класса, которое должно быть учтено.
        """
        if task_type in ["apiclient", "service", "viewmodel", "screen", "entity"]:
            if not sample_file_path:
                raise ValueError("Для задач создания необходимо указать путь к файлу-образцу.")
            if not new_file_name:
                raise ValueError("Для задач создания необходимо указать имя нового файла.")
            sample_code = self.read_file_content(sample_file_path)
            if not sample_code:
                raise ValueError("Не удалось прочитать пример кода.")
            prompt = self.creation_agent.generate_prompt(task_description, sample_code)
            result = await Runner.run(self.creation_agent, prompt)
            generated_code = result.final_output
            directory = os.path.dirname(sample_file_path)
            new_file_path = os.path.join(directory, new_file_name)
            with open(new_file_path, "w", encoding="utf-8") as f:
                f.write(generated_code)
            return generated_code

        elif task_type == "entity from JSON":
            if not sample_file_path:
                raise ValueError("Для задач создания необходимо указать путь к файлу-образцу.")
            if not new_file_name:
                raise ValueError("Для задач создания необходимо указать имя нового файла.")
            if not class_json:
                raise ValueError("Для задачи 'entity from JSON' необходимо предоставить JSON представление класса.")
            sample_code = self.read_file_content(sample_file_path)
            if not sample_code:
                raise ValueError("Не удалось прочитать пример кода.")
            prompt = self.entity_from_json_creation_agent.generate_prompt(task_description, sample_code, class_json)
            result = await Runner.run(self.entity_from_json_creation_agent, prompt)
            generated_code = result.final_output
            directory = os.path.dirname(sample_file_path)
            new_file_path = os.path.join(directory, new_file_name)
            with open(new_file_path, "w", encoding="utf-8") as f:
                f.write(generated_code)
            return generated_code

        elif task_type == "screen":
            if not sample_file_path:
                raise ValueError("Для UI/UX задач необходимо указать путь к файлу-образцу.")
            if not new_file_name:
                raise ValueError("Для UI/UX задач необходимо указать имя нового файла.")
            current_content = self.read_file_content(sample_file_path)
            if current_content is None:
                raise ValueError("Не удалось прочитать пример кода.")
            prompt = self.ui_creation_agent.generate_prompt(task_description, current_content)
            result = await Runner.run(self.ui_creation_agent, prompt)
            generated_code = result.final_output
            directory = os.path.dirname(sample_file_path)
            new_file_path = os.path.join(directory, new_file_name)
            with open(new_file_path, "w", encoding="utf-8") as f:
                f.write(generated_code)
            return generated_code

        elif task_type == "integration":
            if not sample_file_path:
                raise ValueError("Для интеграционных задач необходимо указать путь к файлу для обновления.")
            current_content = self.read_file_content(sample_file_path)
            if current_content is None:
                raise ValueError("Не удалось прочитать пример кода.")
            prompt = self.updater_agent.generate_prompt(task_description, current_content)
            result = await Runner.run(self.updater_agent, prompt)
            updated_code = result.final_output
            with open(sample_file_path, "w", encoding="utf-8") as f:
                f.write(updated_code)
            return updated_code

        else:
            raise ValueError("Неверный тип задачи.")
