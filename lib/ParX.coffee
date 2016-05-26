_ = require 'lodash'
Q = require 'q'
EventEmitter = require("events").EventEmitter

###
Public: Executes tasks in parallel. 

###
class ParX extends EventEmitter

  Object.defineProperty @prototype, 'all',
    get : -> @allTasks

  # Public: Create a ParX sequential executor
  #
  # * `opts` {Object} options
  #    * `manual` {Boolean} If set, don't start immediate task execution
  #    * `context` optional context {Object} which is passed to tasks
  #
  constructor : ( opts = {} ) ->
    @manual = opts.manual or false
    @context = opts.context if opts.context?
    @taskList = []
    @_abort = false
    @count = 0
    @allTasks = Q(true)
    @start()

  # Public: Start the executor 
  #
  start : =>
    return if @started
    @started = true
    @emit 'start'

  # Public: Add the given task(s) to the queue
  #
  # * `list...` a {Function} or array of {Function}s to add to
  # the to add to the queue
  #
  # Returns {Promise} which resolves when the task(s) complete
  #
  add : ( list... ) =>
    wrap = ( fn ) =>
      id = @count++
      x = Q.fcall fn, id, @context
      x.then ( res ) => @emit 'completed', res, id, @context
      @emit 'task', fn
      x

    list = _.flattenDeep [list]
    tasks = (wrap(f) for f in list)
    tasks.push @allTasks
    @allTasks = Q.all tasks

  # Public: Abort pending tasks. Executor will throw an exeption
  #  which can be caught with a promise .fail() handler
  #
  abort : =>
    @_abort = true
    @emit 'abort'

module.exports = ParX