git = require 'gitteh-promisified'
{join, series, map, empty} = require 'reduced'

previousCommits = (commit) ->
  getCommit = (id) ->
    commit.then (commit) ->
      commit.repository.commit(id)

  getPreviousCommit = (commit) ->
    if commit.parents.length > 0
      parents = map commit.parents, getCommit
      join(map parents, previousCommits)
    else
      empty()

  join series(getPreviousCommit, commit)

module.exports = (ref) ->
  previousCommits ref.repository.commit ref.target
