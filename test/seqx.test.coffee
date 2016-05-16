should = require("should")
assert = require("assert")
seqx = require('../index')

describe "seqx", ->

  it "returns a promise for the added task", ( done ) ->
    p = seqx().add -> 1
    p.then ( x ) ->
      x.should.equal 1
      done()
    .fail done
    .done()

  it "emits 'completed' when task is done", ( done ) ->
    seqx()
    .on 'completed', ( result, id ) ->
      result.should.equal 1
      id.should.equal 0
      done()
    .add -> 1
    .fail done
    .done()

  it "passes the result of a task to the next", ( done ) ->
    s = seqx()
    s.add -> 1
    p = s.add ( x ) -> x + 1
    p.then ( x ) ->
      x.should.equal 2
      done()
    .fail done
    .done()

  it "executes tasks in sequence", ( done ) ->
    s = new seqx.SeqX()
    res = []
    s.add -> res.push 1
    s.add -> res.push 2
    s.add -> res.push 3
    s.add -> res.push 4
    p = s.add -> res.push 5
    p.then ->
      assert.deepEqual res, [ 1, 2, 3, 4, 5 ]
      done()
    .fail done
    .done()

  it "call with an array of tasks", ( done ) ->
    s = seqx()
    res = []
    s.add (-> res.push 1),
      (-> res.push 2),
      (-> res.push 3),
      (-> res.push 4),
      (-> res.push 5)
    .then ->
      assert.deepEqual res, [ 1, 2, 3, 4, 5 ]
      done()
    .fail done
    .done()

  it "passes a task counter as the second argument", ( done ) ->
    s = seqx()
    res = []
    s.add ( val, i ) -> res.push i
    s.add ( val, i ) -> res.push i
    s.add ( val, i ) -> res.push i
    s.add ( val, i ) -> res.push i
    s.add ( val, i ) -> res.push i
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

  it "add a task 'n' times", ( done ) ->
    s = seqx()
    res = []
    s.addn (( val, i ) -> res.push i), 5
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

  it "passes a context object as the third argument to a task", ( done ) ->
    res = []
    seqx context : res
    .addn (( val, i, context ) -> context.push i), 5
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

  it "disable auto start", ( done ) ->
    res = []
    s = seqx context : res, manual : true

    s.addn (( val, i, context ) -> context.push i), 5
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

    setTimeout s.start, 500

  it "can be aborted", ( done ) ->
    s = seqx()
    res = []
    p = s.addn (( val, i ) -> res.push i), 5
    s.abort()
    p.then ->
      done "Should't get here"
    .fail ( err ) ->
      err.message.should.equal "Aborted by user"
      done()
