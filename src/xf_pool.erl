-module (xf_pool).
-export ([init/1]).

init (Max) ->
    process_flag(trap_exit, true),
    loop (Max, [], queue: new ()).

loop (Max, Running, Queue) ->
    receive
	{queue, Jobs} ->
	    In = fun (Job, Q) -> queue: in (Job, Q) end,
	    New_q = lists: foldl (In, Queue, Jobs),
	    run (Max, Running, New_q);
	{'EXIT', Pid, _} ->
	    {value, {Pid}, New_r} = lists: keytake (Pid, 1, Running),
	    run (Max, New_r, Queue);
	stop ->
	    bye
    end.

run (Max, Running, Queue) when length (Running) < Max ->
    case queue: out (Queue) of
	{{value, Fun}, New_q} ->
	    Pid = spawn_link (Fun),
	    run (Max, [{Pid} | Running], New_q);
	{empty, Queue} ->
	    loop (Max, Running, Queue)
    end;
run (Max, Running, Queue) when length(Running) >= Max ->
    loop (Max, Running, Queue).