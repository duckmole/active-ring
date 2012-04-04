-module (xf_pool_test).
-test (exports).
-export ([basic/0]).
-export ([resists_crashing_jobs/0]).

basic () ->
    Self = self(),
    Refs = [make_ref() || _ <- [1,2,3]],
    Jobs = [fun()->timer:sleep(1000), Self ! Ref end || Ref <- Refs],
    Pool = spawn_link (xf_pool, init, [2]),
    Pool ! {queue, Jobs},
    Start = now (),
    Refs = lists: sort (receive_n (3)),
    Finish = now (),
    Diff_micro = adlib: now_diff (Start, Finish),
    {two_concurrent, true} = {two_concurrent, Diff_micro < 2200000},
    {three_concurrent, false} = {three_concurrent, Diff_micro < 1200000},
    Pool ! stop,
    timer:sleep (500),
    false = is_process_alive (Pool).

resists_crashing_jobs () ->
    Die = [fun()->timer:sleep(1000), throw(suicide) end || _ <- [1,2,3,4]],
    Self = self(),
    Ref = make_ref (),
    Job = fun() -> timer:sleep(1000), Self ! Ref end,
    Pool = spawn_link (xf_pool, init, [2]),
    Pool ! {queue, Die ++ [Job]},
    Start = now (),
    [Ref] = lists: sort (receive_n (1)),
    Finish = now (),
    Diff_micro = adlib: now_diff (Start, Finish),
    {two_concurrent, true} = {two_concurrent, Diff_micro < 3200000},
    {more_concurrent, false} = {more_concurrent, Diff_micro < 2200000},
    true = is_process_alive (Pool),
    Pool ! stop,
    timer:sleep (500),
    false = is_process_alive (Pool).
    
receive_n (N) ->
    receive_n (N, []).

receive_n (0, Acc) ->
    Acc;
receive_n (N, Acc) ->
    receive
	Msg ->
	    receive_n (N-1, [Msg | Acc])
    after 5000 ->
	    {timeout, Acc}
    end.
