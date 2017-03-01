compile: slackbot.nim slackbot.nim.cfg
	mkdir -p bin
	nim c -d:release slackbot

# install:
# 	mkdir -p ~/bin
	# echo "export PATH=$PATH:~/bin" >> bash_profile
