extends Control


var allRoundData:Dictionary = {}  # {round1:[{answer: x, points: y}, {...}]}
var roundArray:Array = []
var client
var currentRoundIndex = 0


func _ready():
	# get client
	client = get_tree().get_root().get_node("Main/Client")
	# connect show buttons
	for tab in $AnswerSection.get_children():
		var showButton = tab.get_node("ShowToggle")
		showButton.connect("pressed", self, "toggle_button_pressed", [showButton])
	# connect sound buttons
	for soundButton in get_node("SoundSection").get_children():
		soundButton.connect("pressed", self, "sound_button_pressed", [soundButton])
	# connect x buttons
	for xButton in get_node("XButtons").get_children():
		xButton.connect("pressed", self, "x_button_pressed", [xButton])
	# connect button to start the round
	$StartRoundButton.connect("pressed", self, "start_round_button_pressed")


func hostShowScreen():
	self.show()
	hostLoadAnswerDataFromFile()
	hostDisplayRoundTabs()
	hostResetRound()


func x_button_pressed(button:Button):
	client.rpc("clientShowXButton", button.name)


func toggle_button_pressed(button:Button):
	if button.text == "Show":
		button.get_parent().color = Color("#6ad41b")
		client.rpc("clientShowAnswer", int(button.get_parent().name.split("")[-1])-1)
		button.text = "Hide"
	else:
		button.get_parent().color = Color("#ea1919")
		client.rpc("clientHideAnswer", int(button.get_parent().name.split("")[-1])-1)
		button.text = "Show"


func start_round_button_pressed():
	client.rpc("clientDisplayRound", allRoundData[roundArray[currentRoundIndex]], roundArray[currentRoundIndex])
	hostDisplayRound(allRoundData[roundArray[currentRoundIndex]], roundArray[currentRoundIndex])


func sound_button_pressed(button:Button):
	client.rpc("clientPlaySound", button.text.split(" ")[-1].to_lower())


func round_select_button_pressed(button:Button):
	# the button name is the index of the answers to the round
	if currentRoundIndex == int(button.name) -1:
		return
	currentRoundIndex = int(button.name) -1
	hostResetRound()


# the host will load the round data from a file
func hostLoadAnswerDataFromFile():
	var file = File.new()
	file.open("res://answers.csv", file.READ)
	var content = file.get_as_text()
	var lines = content.split("\n")
	var currentRound = ""
	for line in lines:
		if line.begins_with("#"):
			currentRound = line.replace("#", "")
			roundArray.append(currentRound)
			allRoundData[currentRound] = []
		elif not line:
			continue
		else:
			allRoundData[currentRound].append({"answer": line.split(",")[0], "points": line.split(",")[1]})
	print(allRoundData)
	file.close()


func hostDisplayRoundTabs():
	for value in allRoundData:
		var roundButton = Button.new()
		roundButton.text = value
		roundButton.rect_min_size.x = 100
		roundButton.name = value.split(" ")[-1]
		$RoundSelectioContainer.add_child(roundButton)
		roundButton.connect("pressed", self, "round_select_button_pressed", [roundButton])


# this will display the round in the host control panel
func hostDisplayRound(answersArray:Array, roundName:String):
	var answerSlots = $AnswerSection.get_children()
	# add answer and point data to the slots on the client screen
	for index in range(len(answerSlots)):
		var slot = answerSlots[index]
		hostResetAnswerSlot(slot)
		# if there is an answer at the index, display it
		if len(answersArray) > index:
			slot.get_node("AnswerText").bbcode_text = "[center]" + answersArray[index]["answer"] + "[/center]"
			slot.get_node("ScoreBackground/ScoreText").bbcode_text = "[center]" + answersArray[index]["points"].replace(" ", "") + "[/center]"
		# if there is no answer at the slot, disable it
		else:
			slot.get_node("ShowToggle").disabled = true
			slot.color = Color("#786a6a")


func hostResetRound():
	var answerSlots = $AnswerSection.get_children()
	# add answer and point data to the slots on the client screen
	for index in range(len(answerSlots)):
		var slot = answerSlots[index]
		hostResetAnswerSlot(slot)
		slot.get_node("AnswerText").bbcode_text = "Round not started"
		slot.get_node("ShowToggle").disabled = true


func hostResetAnswerSlot(slot):
	slot.get_node("AnswerText").bbcode_text = ""
	slot.color = Color("#ea1919")
	slot.get_node("ScoreBackground/ScoreText").bbcode_enabled = true
	slot.get_node("ScoreBackground/ScoreText").bbcode_text = ""
	slot.get_node("ShowToggle").disabled = false
	slot.get_node("ShowToggle").text = "Show"






