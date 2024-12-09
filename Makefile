git:
	git add .
	git commit -a -m "$m"
	git push -u origin main

build_runner:
	dart pub run build_runner build