%%%-------------------------------------------------------------------
%% @doc queuebuf top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(queuebuf_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).


%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    SupFlags = #{
      strategy  => one_for_one,
      intensity => 1000,
      period    => 3600
     },

    Spec = #{
      id       => 'echo_server',
      start    => {'echo_server', start_link, []},
      restart  => permanent,
      shutdown => 2000,
      type     => supervisor ,
      modules  => ['echo_server']
     },
    {ok, {SupFlags, [Spec]} }.

%%====================================================================
%% Internal functions
%%====================================================================
