-module (xf_test_pool).
-export ([init/2, init/3]).
-record (state, {node, max, parent, running, queue}).

init (Max, Pid) ->
    Node = integrator: slave (),
    init (Node, Max, Pid).

init (Node, Max, Pid) ->
    State = #state{node=Node, max=Max, parent=Pid, running=[], queue=queue:new()},
    loop (State).

loop (State) ->
    receive
	{queue, Test} ->
	    Q = queue: in (Test, State#state.queue),
	    run (State#state{queue=Q});
	{test, M, F, _}=Msg ->
	    State#state.parent ! Msg,
	    run (State#state {running = lists: delete ({M, F}, State#state.running)});
	stop ->
	    bye
    end.

run (#state{max=Max, running=Running}=State) when length (Running) < Max ->
    case queue: out (State#state.queue) of
	{{value, {M, F, A}}, Q} ->
	    spawn_link (State#state.node, consul, test, [M, F, A, self ()]),
	    run (State#state{running=[{M, F} | Running], queue=Q});
	{empty, _} ->
	    loop (State)
    end;
run (State) ->
    loop (State).
