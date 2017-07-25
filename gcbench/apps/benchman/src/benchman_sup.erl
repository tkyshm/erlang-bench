%%%-------------------------------------------------------------------
%% @doc benchman top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(benchman_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    SupFlags = #{
      strategy  => one_for_one,
      intensity => 1000,
      period    => 3600
     },

    Spec = #{
      id       => 'benchman_server',
      start    => {'benchman_server', start_link, []},
      restart  => permanent,
      shutdown => 2000,
      type     => worker,
      modules  => ['benchman_server']
     },

    {ok, {SupFlags, [Spec]}}.

%%====================================================================
%% Internal functions
%%====================================================================
