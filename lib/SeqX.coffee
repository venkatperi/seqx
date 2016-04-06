Q = require 'q'
EventEmitter = require( "events" ).EventEmitter

# Sequential task executor 
module.exports = class SeqX extends EventEmitter

  # Public: constructor
  #
  # * `opts` options
  #    * manual - {Boolean} If set, don't start immediate task execution
  #    * context - {Object} optional context object, passed to tasks
  #
  constructor : ( opts = {} ) ->
    @manual = opts.manual or false
    @context = opts.context if opts.context?

    @initial = Q.defer()
    @task = @initial.promise
    @started = false
    @taskQueue = []

    @_abort = false
    @count = 0
    @start() unless @manual

  # Public: Begin executing tasks
  #
  start : =>
    return if @started
    @started = true
    @initial.resolve true
    @emit "start"

  # Public: Add the given task(s) to the queue
  #
  # * `fn... ` {Function}|[{Function}] One or more tasks to add to the queue
  #
  # Returns a promise which resolves when the task(s) complete
  add : ( fn... ) =>
    @actualAdd f for f in fn
    @task

  # Public: Add the given task `n` times
  #
  # * `fn` {Function} The task to add
  # * `n ` {Number} Number of time to execute the task
  #
  # Returns a promise which resolves the last iteration is complete 
  addn : ( fn, n ) =>
    @actualAdd fn for i in [ 0..n - 1 ]
    @task

  # Public: Abort pending tasks. Executor will throw an exeption
  #  which can be caught with a promise .fail() handler
  #
  abort : =>
    @_abort = true
    @emit "abort"

  # Private: Adds the task to the seq queue
  #
  # * `fn ` The task to add {Function}
  #
  actualAdd : ( fn ) =>
    f = ( args ) => Q.fcall fn, args, @count++, @context
    @task = @task
    .then ( args ) =>
      throw new Error "Aborted by user" if @_abort
      f args
    @emit "task", fn
      


