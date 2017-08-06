%%%-------------------------------------------------------------------
%% @doc gcbench public API
%% @end
%%%-------------------------------------------------------------------

-module(gcbench_app).

-behaviour(application).

%% API
-export([profile_output/0,
         fprof_start/1
        ]).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================
-spec profile_output() -> ok.
profile_output() ->
    fprof:trace([stop]),
    fprof:profile([]),
    fprof:analyse([{dest, "gcbench.analyze"}]),
    fprof:stop().

-spec fprof_start(pid()) -> ok.
fprof_start(Pid) ->
    {ok, _Pid} = fprof:start(),
    fprof:trace([start, {procs, Pid}]).

start(_StartType, _StartArgs) ->
    gcbench_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.
