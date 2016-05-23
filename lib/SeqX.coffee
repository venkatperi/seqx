Q = require 'q'
EventEmitter = require("events").EventEmitter

###
Public: {SeqX} Execute tasks sequentially.

Result of a task is passed to the next. Returns promises which resolve
when tasks are completed. Fires events when tasks are completed.

# Events

## start
Public: Fired when task execution begins.

## task
Public: Fired when a new task is added.
* `fn` {Function} the task which was added.

## completed
Public: Fired when a  task is completed. Callback receives the result of the
 task, the task id and the context, if any.

* `result` the result of the previous task, if any
* `id` {Int} the task's id
* `context` (optional) context {Object} given when the executor was created

## abort
Public: Fired if `abort()` is called on the executor.


# Tasks
Tasks are functions. A task can receive one or more arguments, in
  the following order:

1. `result` The result from the previous task. Can be `undefined`.
2. `id` The task's id which is an incrementing counter.
3. `context` An optional context object which is was supplied when the executor was created.

```javascript
function task(result, id, context) {
  return valueForNextTask;
 }
```

###
class SeqX extends EventEmitter

  # Public: Create a SeqX sequential executor
  #
  # * `opts` {Object} options
  #    * `manual` {Boolean} If set, don't start immediate task execution
  #    * `context` optional context {Object} which is passed to tasks
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

  # Public: Start the executor 
  #
  start : =>
    return if @started
    @started = true
    @initial.resolve true
    @emit 'start'

  # Public: Add the given task(s) to the queue
  #
  # * `fn...` a {Function} or array of {Function}s to add to the to add to the queue
  #
  # Returns {Promise} which resolves when the task(s) complete
  #
  add : ( fn... ) =>
    @actualAdd f for f in fn
    @task

  # Public: Add the given task `n` times
  #
  # * `fn` {Function} task 
  # * `n ` {Number} of time to execute the task
  #
  # Returns {Promise} which resolves the last iteration is complete
  #
  addn : ( fn, n ) =>
    @actualAdd fn for i in [ 0..n - 1 ]
    @task

  # Public: Abort pending tasks. Executor will throw an exeption
  #  which can be caught with a promise .fail() handler
  #
  abort : =>
    @_abort = true
    @emit 'abort'

  # Private: Adds the task to the seq queue
  #
  # * `fn` {Function} task 
  #
  actualAdd : ( fn ) =>
    f = ( args ) =>
      id = @count++
      x = Q.fcall fn, args, id, @context
      x.then ( res ) => @emit 'completed', res, id, @context
      x
    @task = @task
    .then ( args ) =>
      throw new Error 'Aborted by user' if @_abort
      f args
    @emit 'task', fn
      

module.exports = SeqX