#!/usr/bin/env escript
%% -*- erlang -*-
%%! -smp enable -name bench@127.0.0.1 -setcookie queuebuf +K true +P 500000
main([NodeStr]) ->
    chdir(),
    load(),

    Node = list_to_atom(NodeStr),

    io:format("start bench at ~p~n~n", [node()]),
    io:format("timeout\tsent\ttime(msec)\trate(req/sec)~n"),

    buff_router:start_link(),

    lists:foreach(fun(N) ->
        bench_server:start_bench(N, Node)
    end, [1000,10000,50000,100000,200000]).

load() ->
    case filelib:ensure_dir("./ebin") of
        ok -> ok;
        _ -> file:make_dir("./ebin")
    end,
    compile:file("./bench_server.erl", [{outdir, "./ebin"}]),
    compile:file("../src/buff_router.erl", [{outdir, "./ebin"}]),
    code:add_patha("./ebin").

chdir() ->
    {ok, Cwd} = file:get_cwd(),
    D = iolist_to_binary([Cwd, "/", ?FILE]),
    c:cd(filename:dirname(D)).
