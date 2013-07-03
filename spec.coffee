{equal} = require 'assert'
{join} = require 'path'
git = require 'gitteh-promisified'
{log, logSeq} = require './index'

describe 'gitteh-log', ->

  branch = git.openRepository(join __dirname, '.git')
    .then (repo) -> repo.reference("refs/heads/master")

  it 'works', (done) ->
    branch
      .then (branch) ->
        log(branch)
      .then (log) ->
        log.reverse()
        equal log[0].id, '624558d1f88b4c0a675fb53c2cccb6baa4ba6b1c'
        done()
      .fail(done)
      .end()
