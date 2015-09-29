# a more consistent version of Meteor.asyncWrap
Future = Npm.require('fibers/future')

U.syncify = (f) ->
  (args...) ->
    fut = new Future()
    callback = Meteor.bindEnvironment (error, result) ->
      if error
        fut.throw(error)
      else
        fut.return(result)
    f.apply(this, args.concat(callback))
    return fut.wait()
