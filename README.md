# gitteh-log

    git = require 'gitteh-promisified'
    log = require 'gitteh-log'

    git.openRepository('.git')
      .then (repo) ->
        repo.reference('refs/heads/master')
      .then (ref) ->
        log(ref)
      .then (commits) ->
        console.log commits
