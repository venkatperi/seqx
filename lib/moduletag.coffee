path = require 'path'
strRight = require "underscore.string/strRight"
strLeft = require "underscore.string/strLeft"
pkgInfo = require "pkginfo-async"
walkup = require "node-walkup"
Q = require 'q'

createTag = ( mod, pkg ) ->
  filename = mod.filename or mod.id
  basePath = pkg.dirname
  dir = path.dirname filename
  baseName = path.parse( filename ).name
  tag = path.join dir, baseName
  tag = strRight tag, basePath
  tag = strRight tag, '/'
  tag

moduleTag = ( mod, cb ) ->
  pkgPath = []
  dir = path.dirname( mod.filename or mod.id ) unless typeof mod is "string"
  walkup "package.json", cwd : dir, ( err, matches ) ->
    for m in matches
      do ( m ) ->
        defer = Q.defer()
        pkgPath.push defer.promise
        pkgInfo m.dir, ( err, pkg ) ->
          return defer.reject err if err?
          defer.resolve pkg

    Q.all( pkgPath )
    .then ( all ) ->
      suffix = createTag mod, all[ 0 ]
      names = for p in all.reverse()
        p.name
      tag = names.join ":"
      tag += ":#{suffix}"
      cb null, tag
    .fail ( err ) -> cb err


module.exports = moduleTag



