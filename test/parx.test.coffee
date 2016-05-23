should = require("should")
assert = require("assert")
ParX = require('../lib/ParX')

describe "parx", ->

  it "waits for all tasks to complete", ( done ) ->
    parx = new ParX()
    count = 0
    for i in [ 1..10 ]
      parx.add -> count++

    parx.all().then ->
      parx.count.should.equal 10
      count.should.equal 10
      done()
    .fail done
    .done()

  it "add more tasks after first batch", ( done ) ->
    parx = new ParX()
    count = 0
    for i in [ 1..10 ]
      parx.add -> count++

    parx.all().then ->
      for i in [ 1..10 ]
        parx.add -> count++
      parx.all()
    .then ->
      parx.count.should.equal 20
      count.should.equal 20
      done()
    .fail done
    .done()



