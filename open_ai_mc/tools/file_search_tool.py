import os
from pathlib import Path

class FileSearchTool:
    def __init__(self, root_folder, file_extension):
        self.root_folder = root_folder
        self.file_extension = file_extension

    def set_root_folder(self, new_root_folder):
        """
        Updates the root folder to a new path.
        """
        self.root_folder = new_root_folder

    def search_files(self):
        """
        Returns a list of all files in the project with the specified file extension.
        """
        result = []
        for root, dirs, files in os.walk(self.root_folder):
            for f in files:
                if f.endswith(self.file_extension):
                    full_path = Path(root) / f
                    result.append(str(full_path))
        return result
