should = require( "should" )
assert = require( "assert" )
Seq = require( '../index' )

describe "seq", ->

  it "returns a promise for the addded task", ( done ) ->
    seq = new Seq()
    p = seq.add -> 1
    p.then ( x ) ->
      x.should.equal 1
      done()
    .fail done
    .done()

  it "passes the result of a task to the next", ( done ) ->
    seq = new Seq()
    seq.add -> 1
    p = seq.add ( x ) -> x + 1
    p.then ( x ) ->
      x.should.equal 2
      done()
    .fail done
    .done()

  it "executes tasks in sequence", ( done ) ->
    seq = new Seq()
    res = []
    seq.add -> res.push 1
    seq.add -> res.push 2
    seq.add -> res.push 3
    seq.add -> res.push 4
    p = seq.add -> res.push 5
    p.then ->
      assert.deepEqual res, [ 1, 2, 3, 4, 5 ]
      done()
    .fail done
    .done()

  it "call with an array of tasks", ( done ) ->
    seq = new Seq()
    res = []
    seq.add (-> res.push 1),
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
    seq = new Seq()
    res = []
    seq.add ( val, i ) -> res.push i
    seq.add ( val, i ) -> res.push i
    seq.add ( val, i ) -> res.push i
    seq.add ( val, i ) -> res.push i
    seq.add ( val, i ) -> res.push i
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

  it "add a task 'n' times", ( done ) ->
    seq = new Seq()
    res = []
    seq.addn (( val, i ) -> res.push i), 5
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

  it "passes a context object as the third argument to a task", ( done ) ->
    res = []
    seq = new Seq context: res
    seq.addn (( val, i, context ) -> context.push i), 5
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

  it "disable autostart", ( done ) ->
    res = []
    seq = new Seq context: res, manual: true
    seq.addn (( val, i, context ) -> context.push i), 5
    .then ->
      assert.deepEqual res, [ 0, 1, 2, 3, 4 ]
      done()
    .fail done
    .done()

    setTimeout seq.start, 500


