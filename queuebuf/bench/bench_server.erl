%%%-------------------------------------------------------------------
%%% @author tkyshm
%%% @copyright (C) 2017, tkyshm
%%% @doc
%%%
%%% @end
%%% Created : 2017-07-22 11:25:05.464608
%%%-------------------------------------------------------------------
-module(bench_server).

%% API
-export([
         start_bench/1,
         start_bench/2
        ]).

-define(SERVER, ?MODULE).

-record(state, {
    start = 0 :: non_neg_integer(),
    count = 0 :: non_neg_integer(),
    timeout_cnt = 0 :: non_neg_integer(),
    fin_pid = undefined :: pid()
}).

start_bench(Num) ->
    start_bench(Num, node()).

start_bench(Num, Node) ->

    Start = erlang:system_time(millisecond),

    FinPid = self(),
    Pid = spawn_link(fun() ->
        loop(Num, #state{fin_pid=FinPid,start=Start})
    end),

    register(bench_server, Pid),

    send_echo(Num, Node),

    receive
        finish ->
            case whereis(bench_server) of
                undefined ->
                    ok;
                Pid ->
                    exit(Pid, normal),
                    unregister(echo_server)
            end
    end.

loop(Num, #state{start=Start,count=Cnt,timeout_cnt=TCnt,fin_pid=Fin}) when Num =:= Cnt + TCnt ->
    print_result(Start, erlang:system_time(millisecond), Cnt, TCnt),
    Fin ! finish;
loop(Num, State = #state{count=Cnt, timeout_cnt=TCnt}) ->
    receive
        _Msg ->
            loop(Num, State#state{count=Cnt+1})
    after 3000 ->
        loop(Num, State#state{timeout_cnt=TCnt+1})
    end.

send_echo(0, _) ->
    ok;
send_echo(N, ToNode) ->
    spawn(buff_router, route, [ToNode, echo_server, {echo, node(), bench_server, <<"echo message">>}]),
    send_echo(N-1, ToNode).

%% private
print_result(Start, End, Num, TNum) ->
    Diff = End-Start,
    io:format("~p\t~p\t~p\t~f~n",[TNum, Num, Diff, Num*1000/Diff]).
