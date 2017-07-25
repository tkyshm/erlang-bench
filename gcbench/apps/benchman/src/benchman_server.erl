%%%-------------------------------------------------------------------
%%% @author tkyshm
%%% @copyright (C) 2017, tkyshm
%%% @doc
%%%
%%% @end
%%% Created : 2017-07-25 09:11:11.595647
%%%-------------------------------------------------------------------
-module(benchman_server).

-behaviour(gen_server).

%% API
-export([start_link/0]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

%% timeout 3 sec
-define(TIMEOUT, 3000).

-record(state, {
    num = 0 :: non_neg_integer(),
    start = 0 :: non_neg_integer(),
    count = 0 :: non_neg_integer(),
    timeout = 0 :: non_neg_integer(),
    fin_pid = undefined :: pid()
}).

%%%===================================================================
%%% API
%%%===================================================================

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, #state{}}.

handle_call({prepare, Num}, _From, State) ->
    {reply, ok, State#state{num=Num, count=0, timeout=0, start=erlang:system_time(millisecond)}}.

handle_cast({start, Num, FinPid, Req}, State) ->
    send_message(Num, Req),
    {noreply, State#state{fin_pid=FinPid}, ?TIMEOUT};
handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(timeout, State = #state{timeout=TCnt}) ->
    {noreply, State#state{timeout=TCnt+1}, ?TIMEOUT};
handle_info(_Msg, State = #state{start=Start,fin_pid=FinPid,count=Cnt,timeout=TCnt,num=Num}) when Num-1 =:= Cnt+TCnt ->
    print_result(Start, Num, Cnt+1, TCnt),
    FinPid ! finish,
    {noreply, State};
handle_info(_Msg, State = #state{count=Cnt}) ->
    {noreply, State#state{count=Cnt+1}, ?TIMEOUT}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
        {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
send_message(0, _Req) ->
    ok;
send_message(N, Req = {Module, Fun, Args}) ->
    spawn(Module, Fun, Args),
    send_message(N-1, Req).

print_result(Start, Num, Cnt, TCnt) ->
    Diff = erlang:system_time(millisecond) - Start,
    io:format("~p\t~p\t~p\t~f~n",[TCnt, Cnt, Diff, Num*1000/Diff]).
