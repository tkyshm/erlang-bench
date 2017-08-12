gcbench
=====

process message passing bench

Build
-----

    $ rebar3 compile

Bench

- sys.config

```erlang
[
  {buff_router, [
    {message_queue_data, on_heap} % buff_router process's message_queue_data flag: on_heap | off_heap
  ]},
  {gcbench,  [
    {router, buff_router},        % use buffer router: default 'undefined' == no buffer
    {message_queue_data, on_heap} % gcbench_server process's message_queue_data flag: on_heap | off_heap
  ]},
  {benchman, [
    {message_queue_data, on_heap} % benchman_server process's message_queue_data flag: on_heap | off_heap
  ]}
].
```

-----

    %% node A

    $ ERL_FLAGS='-args_file config/vm-bench.args'  r3 shell

    %% node B
    $ ERL_FLAGS='-args_file config/vm.args' r3 shell


    %% at node A
    1> benchman:start_bench_preset('bacon@127.0.0.1').

