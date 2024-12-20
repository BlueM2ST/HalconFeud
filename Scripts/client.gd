extends Control


var roundEnded = false


func clientShowScreen():
	self.show()


# play sound from file name
remote func clientPlaySound(sound:String):
	# create new AudioStreamPlayer2D
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	audioPlayer.stream = load("res://Sounds/" + sound + ".mp3")
	audioPlayer.play()
	# once the finished signal is emitted, free the player
	yield(audioPlayer, "finished")
	audioPlayer.queue_free()


# this will display the round to the audience, but not show any answers
remote func clientDisplayRound(answersArray:Array, roundName:String):
	roundEnded = false
	get_node("Board/RoundScore/ScoreText").bbcode_text = "[center]0[/center]"
	var answerSlots = $Board/InnerBoard.get_children()
	for index in range(len(answerSlots)):
		var slot = answerSlots[index]
		# reset
		slot.get_node("Show").hide()
		slot.get_node("Hide").hide()
		# if there is an answer at the index, display it
		if len(answersArray) > index:
			slot.get_node("Show/AnswerText").bbcode_text = "[center]" + answersArray[index]["answer"] + "[/center]"
			slot.get_node("Show/ScoreBox/ScoreText").bbcode_text = "[center]" + answersArray[index]["points"].replace(" ", "") + "[/center]"
			slot.get_node("Hide").show()


# show the answer based on id. ids should be 0-7 to match the slots in the array
remote func clientShowAnswer(id:int):
	var answerSlots = $Board/InnerBoard.get_children()
	answerSlots[id].get_node("Hide").hide()
	answerSlots[id].get_node("Show").show()
	# play sound
	clientPlaySound("points")
	# add score to round score
	if not roundEnded:
		var currentScore = int(get_node("Board/RoundScore/ScoreText").bbcode_text)
		currentScore += int(answerSlots[id].get_node("Show/ScoreBox/ScoreText").bbcode_text)
		get_node("Board/RoundScore/ScoreText").bbcode_text = "[center]" + String(currentScore) + "[/center]"


# hide the answer based on id
remote func clientHideAnswer(id:int):
	var answerSlots = $Board/InnerBoard.get_children()
	answerSlots[id].get_node("Hide").show()
	answerSlots[id].get_node("Show").hide()
	# subtract score from round score
	if not roundEnded:
		var currentScore = int(get_node("Board/RoundScore/ScoreText").bbcode_text)
		currentScore -= int(answerSlots[id].get_node("Show/ScoreBox/ScoreText").bbcode_text)
		get_node("Board/RoundScore/ScoreText").bbcode_text = "[center]" + String(currentScore) + "[/center]"


# show x button by index name, play buzzer sound
remote func clientShowXButton(index:String):
	var time = 2
	get_node("XDisplay/" + index).show()
	clientPlaySound("buzzer")
	yield(get_tree().create_timer(time), "timeout")
	get_node("XDisplay/" + index).hide()



remote func clientEndRound(side:String):
	roundEnded = true
	var roundScore = int(get_node("Board/RoundScore/ScoreText").bbcode_text)
	get_node("Board/RoundScore/ScoreText").bbcode_text = "[center]Halcon[/center]"
	if side == "right":
		var currentScore = int(get_node("Board/ScoreRight/ScoreText").bbcode_text)
		currentScore += roundScore
		get_node("Board/ScoreRight/ScoreText").bbcode_text = "[center]" + String(currentScore) + "[/center]"
	else:
		var currentScore = int(get_node("Board/ScoreLeft/ScoreText").bbcode_text)
		currentScore += roundScore
		get_node("Board/ScoreLeft/ScoreText").bbcode_text = "[center]" + String(currentScore) + "[/center]"
	







