git = require 'gitteh-promisified'
{commitTreeEntry} = require 'gitteh-tree-entry'
{all} = require 'kew'
{SKIP, asSeq, produced, reduced, join, series, map, empty, window} = require 'reduced'

# m a, (a -> m bool) -> m a
filterM = (seq, f) ->
  seq = asSeq seq
  next: (done) ->
    seq.next (s, v) ->
      return done(s) if s?
      reduced(asSeq f v)
        .then (allowed) ->
          if allowed then done(null, v) else done(SKIP)
        .end()

changedBetween = (path, commit, prevCommit) ->
  if prevCommit?
    all(commitTreeEntry(commit, path), commitTreeEntry(prevCommit, path))
      .then ([entry, prevEntry]) ->
        created = entry and not prevEntry
        changed = entry?.id != prevEntry?.id
        changed or created
  else
    commitTreeEntry(commit, path)

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

logSeq = (ref, file) ->
  commits = previousCommitsSeq ref.repository.commit(ref.target)
  if file?
    commits = filterM (window commits, 2), ([commit, prevCommit]) ->
      changedBetween(file, commit, prevCommit)
    map commits, ([commit, prevCommit]) -> commit
  else
    commits

log = (ref, file) ->
  produced logSeq(ref, file)

module.exports = {log, logSeq, previousCommitsSeq}
