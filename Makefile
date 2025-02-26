git:
	git add .
	git commit -a -m "$m"
	git push -u origin main

build_runner:
	dart pub run build_runner build

build_runner_delete:
	dart pub run build_runner build --delete-conflicting-outputs

get:
	flutter pub get

gen:
	flutter pub get
	flutter pub run build_runner build --delete-conflicting-outputs