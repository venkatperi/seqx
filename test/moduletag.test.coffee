should = require( "should" )
assert = require( "assert" )
moduleTag = require( '../index' )

describe "moduletag", ->

  it "create module tag", ( done ) ->
    moduleTag module, ( err, tag ) ->
      console.log tag
      tag.should.equal "moduletag:test/moduletag.test"
      done()



