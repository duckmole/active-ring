-module (einotify_test).
-test (exports).
-export ([open_and_close/0]).
-export ([add_watch/0]).

open_and_close () ->
    Port = einotify: open_port (),
    true = is_port (Port),
    Port ! {self(), close},
    ok = receive {Port, closed} -> ok
	 after 2000 -> timeout end.

add_watch () ->
    fixtures: use_tree ([], fun add_watch/2).

add_watch (Root, _) ->
    Port = einotify: open_port (),
    Port ! {self(), {command, "W create " ++ Root}},
    {ok, M} = receive_one (Port),
    {data, "W " ++ Watch_num} = M,
    io: fwrite ("Watch num: ~p~n", [Watch_num]),
    Port ! {self(), close},
    ok = receive {Port, closed} -> ok
	 after 2000 -> timeout end.
    
receive_one (Port) ->
    receive {Port, M} -> M
    after 2000 -> timeout
    end.
	    
%% notify_create () ->
%%     fixtures: use_tree ([], fun notify_create/2).

%% notify_create (Root, _) ->
%%     P = einotify: open_port (),
%%     L = length (Root),
%%     Flags = einotify: flags ([create]),
%%     Path = list_to_binary (Root),
%%     P ! {self(), {command, <<1, Flags:32, L, Path/binary>>}},
%%     M = receive MM -> MM after 2000 -> timeout end,
%%     io:fwrite ("~p~n", [M]),
%%     {P, {data, <<1, Watch:32, L, Path/binary>>}} = M,
%%     %% 	 after 2000 -> timeout_on_watch end,
%%     File = filename: join (Root, "foo"),
%%     ok = file: write_file (File, "foo"),
%%     {ok, Fs} = file: list_dir (Root),
%%     io:fwrite("ls: ~p~n", [Fs]),
%%     {ok, Mask} = receive {P, {data, <<2, Watch:32, M:32>>}} -> {ok, M}
%% 	 after 2000 ->
%% 		 Msg = receive M -> M after 0 -> nothing end,
%% 		 io:fwrite("Unexpected: ~p~n", [Msg]),
%% 		 timeout_on_notify
%% 	 end,
%%     io: fwrite ("Watch: ~p; mask: ~p~n", [Watch, Mask]),
%%     P ! {self(), close},
%%     ok = receive {P, closed} -> ok
%% 	 after 2000 -> timeout_on_close end.


%    Port ! {self (), {command, term_to_binary ({watch, "toto"})}},
    %% ok = receive
    %% 	     {Port, {data, Data}} ->
    %% 		 case binary_to_term (Data) of    %% 		     {watching, "toto"} ->
    %% 			 unexpected;
    %% 		     {error, "toto", _} ->
    %% 			 ok
    %% 		 end
    %% 	 after 1000 -> timeout
    %% 	 end,
    %% true = port_close (Port),
    %% receive M -> io:fwrite ("M: ~p~n",[M]) after 1000 -> timeout end,
    %% ok.

