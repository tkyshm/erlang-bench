%%%-------------------------------------------------------------------
%% @doc gcbench top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(gcbench_sup).

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

    Router = application:get_env(gcbench, router, undefined),

    Spec = #{
      id       => 'gcbench_server',
      start    => {'gcbench_server', start_link, [Router]},
      restart  => permanent,
      shutdown => 2000,
      type     => worker,
      modules  => ['gcbench_server']
     },

    {ok, { SupFlags, [Spec]} }.

%%====================================================================
%% Internal functions
%%====================================================================
