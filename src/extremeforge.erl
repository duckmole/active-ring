%%% Copyright (C) Dominic Williams
%%% All rights reserved.
%%% See file COPYING.

-module (extremeforge).
-export ([start/0, start/2, startseq/0]).
-export ([run/0, run/2, runseq/0]).
-export ([stop/0]).

start () ->
    {ok, CWD} = file: get_cwd (),
    start ([CWD], []).

startseq () ->
    {ok, CWD} = file: get_cwd (),
    start ([CWD], [sequential]).
    
start (Roots, Options) ->
    register (extremeforge, spawn_link (fun () -> init (Roots, Options) end)).

stop () ->
    extremeforge ! stop,
    unregister (extremeforge).

init (Roots, Options) ->
    Rs = [filename: absname (R) || R <- Roots],
    Printer = spawn_link (text_printer, init, [standard_io]),
    Integrator = spawn_link (integrator, init, [Printer, Rs, Options]),
    F = fun (E) -> Integrator ! E end,
    Ws = [spawn_link (directory_watcher, init_recursive, [R, F]) || R <- Rs],
    loop ({Integrator, Printer, Ws}).

loop ({Integrator, Printer, Watchers} = State) ->
    receive stop ->
	    [Pid ! stop || Pid <- [Integrator, Printer | Watchers]],
	    bye
    after 1000 ->
	    [Pid ! check || Pid <- Watchers],
	    loop (State)
    end.

run () ->
    {ok, CWD} = file: get_cwd (),
    run ([CWD], []).

runseq () ->
    {ok, CWD} = file: get_cwd (),
    run ([CWD], [sequential]).
    
run (Roots, Options) ->
    spawn_link (fun () -> init_run (Roots, Options) end).

init_run (Roots, Options) ->
    Rs = [filename: absname (R) || R <- Roots],
    Printer = spawn_link (text_printer, init, [standard_io]),
    Integrator = spawn_link (integrator, init, [self (), Rs, Options]),
    F = fun (E) -> Integrator ! E end,
    Ws = [spawn_link (directory_watcher, init_recursive, [R, F]) || R <- Rs],
    wait_end ({Printer, Integrator, Ws}).

wait_end ({Printer, _, _}=State) ->
    receive Msg -> Printer ! Msg end,
    case Msg of
	{totals, {M, C, E, _, _, _}} when M > C + E ->
	    wait_end (State);
	{totals, {M, M, 0, T, P, F}} when T > P + F ->
	    wait_end (State);
	{totals, {M, C, E, _, _, _}=Totals} when M == C + E ->
	    stop (Totals, State);
	_ ->
	    wait_end (State)
    end.

stop (Totals, {Printer, Integrator, Watchers}) ->
    [Pid ! stop || Pid <- [Printer, Integrator | Watchers]],
    init: stop (exit_code (Totals)).

exit_code ({M, M, 0, T, T, 0}) ->
    0;
exit_code (_) ->
    1.
