%%%-------------------------------------------------------------------
%%% @author tkyshm
%%% @copyright (C) 2017, tkyshm
%%% @doc
%%%
%%% @end
%%% Created : 2017-07-22 15:35:07.290767
%%%-------------------------------------------------------------------
-module(buff_router_server).

-behaviour(gen_server).

%% API
-export([start_link/0,
         route/3
        ]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

-define(BUFF_MAXSIZE, 100).
-define(TIMEOUT, 100).

-type message() :: [{node(), {non_neg_integer(), [term()]}}].

-record(state, {
    msg_buff = [] :: [message()]
}).

start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

route(ToNode, Pname, Msgs) when is_list(Msgs) ->
    lists:foreach(fun(Msg) -> route(ToNode, Pname, Msg) end, Msgs);
route(ToNode, Pname, Msg) ->
    gen_server:cast(?SERVER, {enqueue, ToNode, Pname, Msg}).

init([]) ->
    MQD = application:get_env(buff_router, message_queue_data, on_heap),
    process_flag(message_queue_data, MQD),
    {ok, #state{}, ?TIMEOUT}.

handle_call(_Request, _From, State) ->
    Reply = ok,
    {reply, Reply, State}.

handle_cast({send, Msgs}, State) ->
    lists:foreach(fun({Pname, Msg}) ->
        Pname ! {buff_router, Msg}
    end, Msgs),
    {noreply, State, ?TIMEOUT};
handle_cast({enqueue, ToNode, Pname, Msg}, State = #state{msg_buff=Buff}) when is_atom(ToNode) ->
    NewBuff = buffer_message(ToNode, {Pname, Msg}, Buff),
    {noreply, State#state{msg_buff=NewBuff}, ?TIMEOUT}.

handle_info(timeout, State = #state{msg_buff=Buff}) ->
    flush_buffer(Buff),
    {noreply, State#state{msg_buff=[]}, ?TIMEOUT}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

buffer_message(ToNode, Msg, Buff) ->
    case lists:keysearch(ToNode, 1, Buff) of
        {value, {ToNode, {_, Msgs}}} ->
            case length(Msgs) >= ?BUFF_MAXSIZE of
                false ->
                    Time = erlang:system_time(second),
                    lists:keyreplace(ToNode, 1, Buff, {ToNode, {Time, [Msg|Msgs]}});
                true ->
                    gen_server:cast({?SERVER, ToNode}, {send, [Msg|Msgs]}),
                    lists:keydelete(ToNode, 1, Buff)
            end;
        false ->
            [{ToNode, {erlang:system_time(second), [Msg]}}|Buff]
    end.

flush_buffer(Buff) -> lists:foreach(fun flush_message/1, Buff).

flush_message({ToNode, {_Time, Msgs}}) ->
    gen_server:cast({?SERVER, ToNode}, {send, Msgs}).
