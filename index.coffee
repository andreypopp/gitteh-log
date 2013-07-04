git = require 'gitteh-promisified'
{all, resolve} = require 'kew'
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

treeEntry = (tree, path) ->
  path = path.split('/').filter(Boolean) unless Array.isArray(path)

  for entry in tree.entries when entry.name == path[0]

    if path.length == 1 and entry.type == 'blob'
      return resolve(entry)

    else if path.length > 1 and entry.type == 'tree'
      return tree.repository.tree(entry.id)
        .then (tree) -> treeEntry(tree, path.slice(1))

  return resolve(undefined)

changedBetween = (path, commit, prevCommit) ->
  if prevCommit?
    all(commit.tree(), prevCommit.tree()).then ([tree, prevTree]) ->
      all(treeEntry(tree, path), treeEntry(prevTree, path)).then ([entry, prevEntry]) ->
        created = entry and not prevEntry
        changed = entry?.id != prevEntry?.id
        changed or created
  else
    commit.tree()
      .then (tree) ->
        treeEntry(tree, path)
      .then (entry) ->
        entry?

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
