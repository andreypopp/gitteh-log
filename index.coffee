git = require 'gitteh-promisified'
{produced, join, series, map, empty} = require 'reduced'

previousCommitsSeq = (commit) ->

  getCommit = (id) ->
    commit.then (commit) ->
      commit.repository.commit(id)

  getPreviousCommit = (commit) ->
    if commit.parents.length > 0
      parents = map(commit.parents, getCommit)
      join map(parents, previousCommitsSeq)
    else
      empty()

  join series(getPreviousCommit, commit)

logSeq = (ref) ->
  previousCommitsSeq ref.repository.commit ref.target

log = (ref) ->
  produced logSeq ref

module.exports = {log, logSeq, previousCommitsSeq}
