-- Detect CPU architecture
set cpuArch to do shell script "uname -m"

if cpuArch is equal to "x86_64" then
	-- Intel Mac
	set dockerURL to "https://desktop.docker.com/mac/main/amd64/Docker.dmg"
else
	-- Assume Apple Silicon (arm64)
	set dockerURL to "https://desktop.docker.com/mac/main/arm64/Docker.dmg"
end if

tell application "System Events"
	if exists application file "Docker.app" of folder "/Applications" then
		display notification "Docker is already installed."
	else
		do shell script "curl -L -o ~/Downloads/Docker.dmg " & quoted form of dockerURL
		do shell script "hdiutil attach ~/Downloads/Docker.dmg"
		do shell script "cp -R /Volumes/Docker/Docker.app /Applications/" with administrator privileges
		do shell script "hdiutil detach /Volumes/Docker"
		do shell script "rm ~/Downloads/Docker.dmg"
	end if
end tell



tell application "Docker" to activate

repeat
	try
		do shell script "/Applications/Docker.app/Contents/Resources/bin/docker info > /dev/null 2>&1"
		exit repeat
	on error
		delay 1
	end try
end repeat

tell application "System Events"
	set visible of process "Docker Desktop" to false
end tell
