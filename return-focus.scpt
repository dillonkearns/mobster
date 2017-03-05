tell application "System Events"
	set activeApp to name of application processes whose frontmost is true
	if (activeApp = {"Mobster"} or activeApp = {"Electron"}) then
		tell application "System Events"
			key down command
			keystroke tab
			key up command
		end tell
	end if
end tell
