class_name RecoverState extends State

func enter(args: Array):
	super.enter(args)
	switch_state(StateMachine.IDLE)

func exit():
	super.exit()
	
	#if idle_state_triggered():
	#switch_state(StateMachine.IDLE)
