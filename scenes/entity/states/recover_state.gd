class_name RecoverState extends State

func enter():
	super.enter()
	switch_state(StateMachine.IDLE)

func exit():
	super.exit()
	
	#if idle_state_triggered():
	#switch_state(StateMachine.IDLE)
