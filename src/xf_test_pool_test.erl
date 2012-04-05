-module (xf_test_pool_test).
-test (concurrency).
-export ([concurrency/0]).
-export ([ok_test/0]).
-export ([ko_test/0]).

ok_test () ->
    ok = timer: sleep (900).

ko_test () ->
    ko = timer: sleep (1000).

concurrency () ->
    Node = integrator: slave ("_"?MODULE_STRING"_concurrency"),
    Pool = spawn_link (xf_test_pool, init, [Node, 2, self ()]),
    Pool ! {queue, {timer, sleep, [2000]}},
    Pool ! {queue, {timer, sleep, [2000]}},
    Pool ! {queue, {timer, sleep, [2000]}},
    Start = now (),
    Expected = lists: duplicate (3, {test, timer, sleep, pass}),
    Expected = receive_n (3),
    Finish = now (),
    Diff_micro = adlib: now_diff (Start, Finish),
    {two_concurrent, true} = {two_concurrent, Diff_micro < 5000000},
    {three_concurrent, false} = {three_concurrent, Diff_micro < 3000000},
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
