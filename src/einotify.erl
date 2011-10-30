-module (einotify).
-export ([open_port/0]).
-define (max_line, 4096).

open_port () ->    
    Path = "../priv/einotify",
    Options = [{line,?max_line}, use_stdio, exit_status, hide],
    open_port ({spawn_executable, Path}, Options).
