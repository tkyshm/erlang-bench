%%%-------------------------------------------------------------------
%%% @author tkyshm
%%% @copyright (C) 2017, tkyshm
%%% @doc
%%%
%%% @end
%%% Created : 2017-07-25 09:01:41.143884
%%%-------------------------------------------------------------------
-module(buff_router).

-behaviour(application).

%% API
-export([route/3]).

%% Application callbacks
-export([start/2, stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

route(ToNode, Pname, Msgs) when is_list(Msgs) ->
    lists:foreach(fun(Msg) -> route(ToNode, Pname, Msg) end, Msgs);
route(ToNode, Pname, Msg) ->
    gen_server:cast(buff_router_server, {enqueue, ToNode, Pname, Msg}).

start(_StartType, _StartArgs) ->
    {ok, _Pid} = buff_router_sup:start_link().

stop(_State) ->
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
