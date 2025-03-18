from pathlib import Path

class FileReaderTool:
    def __init__(self, root_folder: str):
        self.root_folder = Path(root_folder)

    def set_root_folder(self, new_root_folder: str):
        """
        Обновляет корневую папку.
        """
        self.root_folder = Path(new_root_folder)

    def read_file_content(self, file_path: str) -> str:
        """
        Читает содержимое файла, путь к которому указывается относительно root_folder.
        """
        full_path = self.root_folder / file_path
        if not full_path.exists() or not full_path.is_file():
            return ""
        try:
            return full_path.read_text(encoding='utf-8')
        except Exception as e:
            print(f"Ошибка при чтении файла {full_path}: {e}")
            return ""
