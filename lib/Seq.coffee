Q = require 'q'

module.exports = class Seq
  constructor : ( opts = {} ) ->
    @manual = opts.manual or false
    @context = opts.context if opts.context?

    @initial = Q.defer()
    @task = @initial.promise
    @started = false
    @taskQueue = []

    @count = 0
    @start() unless @manual

  start : =>
    return if @started
    @started = true
    @initial.resolve true

  actualAdd : ( fn ) =>
    f = ( args ) => Q.fcall fn, args, @count++, @context
    @task = @task.then f

  add : ( fn... ) =>
    @actualAdd f for f in fn
    @task 

  addn : ( fn, n ) =>
    @actualAdd fn for i in [ 0..n - 1 ]
    @task 

