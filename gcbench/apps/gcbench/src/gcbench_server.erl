%%%-------------------------------------------------------------------
%%% @author tkyshm
%%% @copyright (C) 2017, tkyshm
%%% @doc
%%%
%%% @end
%%% Created : 2017-07-22 11:20:24.570552
%%%-------------------------------------------------------------------
-module(gcbench_server).

-behaviour(gen_server).

%% API
-export([start_link/0,
         start_link/1
        ]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

-record(state, {
    router = undefined :: undefined | buff_router
}).

start_link() ->
    start_link(undefined).

start_link(Router) ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [Router], []).

init([Router]) ->
    {ok, #state{router=Router}}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({echo, FromNode, SenderName, Msg}, State = #state{router=Router}) when Router =:= undefined ->
    {SenderName, FromNode} ! Msg,
    {noreply, State};
handle_cast({buff_router, {echo, FromNode, SenderName, Msg}}, State = #state{router=Router}) ->
    Router:route(FromNode, SenderName, Msg),
    {noreply, State}.

handle_info({echo, FromNode, SenderName, Msg}, State = #state{router=Router}) when Router =:= undefined ->
    {SenderName, FromNode} ! Msg,
    {noreply, State};
handle_info({buff_router, {echo, FromNode, SenderName, Msg}}, State = #state{router=Router}) ->
    Router:route(FromNode, SenderName, Msg),
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
