git:
	git add .
	git commit -a -m "$m"
	git push -u origin main

build_runner:
	dart pub run build_runner build

build_runner_delete:
	dart pub run build_runner build --delete-conflicting-outputs