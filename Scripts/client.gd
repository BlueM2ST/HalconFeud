extends Control


func clientShowScreen():
	self.show()


remote func clientPlaySound(sound:String):
	# create new AudioStreamPlayer2D
	var audioPlayer = AudioStreamPlayer2D.new()
	add_child(audioPlayer)
	audioPlayer.stream = load("res://Sounds/" + sound + ".mp3")
	audioPlayer.play()
	# once the finished signal is emitted, free the player
	yield(audioPlayer, "finished")
	audioPlayer.queue_free()


# this will display the round to the audience
remote func clientDisplayRound(answersArray:Array, roundName:String):
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


# hide the answer based on id
remote func clientHideAnswer(id:int):
	var answerSlots = $Board/InnerBoard.get_children()
	answerSlots[id].get_node("Hide").show()
	answerSlots[id].get_node("Show").hide()



