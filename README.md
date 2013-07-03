# gitteh-log

    git = require 'gitteh-promisified'
    log = require 'gitteh-log'
    {produced} = require 'reduced'

    git.openRepository('.git')
      .then (repo) ->
        repo.reference('refs/heads/master')
      .then (ref) ->
        # this function returns a lazy sequence of commits
        # apply produced(seq) to force its evaluation
        seq = log(ref)
        produced(seq)
      .then (commits) ->
        console.log commits
