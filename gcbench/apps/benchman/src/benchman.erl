%%%-------------------------------------------------------------------
%% @doc benchman public API
%% @end
%%%-------------------------------------------------------------------

-module(benchman).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).
-export([start_bench/2,
         start_bench_preset/1
        ]).

%%====================================================================
%% API
%%====================================================================
-spec start_bench(non_neg_integer(), node()) -> ok.
start_bench(Num, Node) ->
    %% 準備
    ok = gen_server:call(benchman_server, {prepare, Num}),

    %% パラメータ
    Req = case application:get_env(gcbench, router, gen_server) of
        buff_router ->
            M = buff_router,
            F = route,
            A = [Node, gcbench_server, {echo, node(), benchman_server, <<"hello hello bacon!!">>}],
            {M, F, A};
        gen_server ->
            M = gen_server,
            F = cast,
            A = [{gcbench_server, Node}, {echo, node(), benchman_server, <<"hello hello bacon!!">>}],
            {M, F, A}
    end,

    %% ベンチ開始
    gen_server:cast(benchman_server, {start, Num, self(), Req}),

    %% 終了メッセージが来るまで待機
    receive
        {finish, Diff, Rate} -> {Diff, Rate}
    end.

-spec start_bench_preset(node()) -> ok.
start_bench_preset(Node) ->
    io:format("start bench at ~p~n~n", [node()]),
    io:format("timeout\tsent\ttime(msec)\trate(req/sec)~n"),

    lists:foreach(fun(N) ->
        start_bench(N, Node)
    end, [1000,10000,50000,100000,200000,300000,500000]).

start(_StartType, _StartArgs) ->
    benchman_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
