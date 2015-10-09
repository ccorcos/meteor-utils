U.isPlainObject = (x) ->
  Object.prototype.toString.apply(x) is '[object Object]'

U.unix = -> Math.round(Date.now()/1000)
U.timestamp = -> Date.now()

# Its nice to have the function last in coffeescript
U.delay = R.curry (ms, f) -> Meteor.setTimeout(f,ms)
U.interval = R.curry (ms, f) -> Meteor.setInterval(f,ms)

U.serialize = (data) -> JSON.stringify(data)
U.deserialize = (data) -> JSON.parse(data)

# shallow clone arrays or objects
U.shallowClone = (x) ->
  if _.isArray(x)
    return x.concat([])
  else if U.isPlainObject(x)
    obj = {}
    for k,v of x
      obj[k] = v
    return obj
  else
    return x

U.extendDeep = R.curry (dest, obj) ->
  for k,v of obj
    if U.isPlainObject(v)
      dest[k] = dest[k] or {}
      U.extendDeep(dest[k], v)
    else
      dest[k] = v
  return

U.mergeDeep = R.curry (dest, obj) ->
  newDest = R.clone(dest)
  for k,v of obj
    if U.isPlainObject(v)
      newDest[k] = U.mergeDeep(newDest[k] or {}, v)
    else
      newDest[k] = R.clone(v)
  return newDest

# a decorator to throw errors or give you the async result
U.throwIfErr = (f) ->
  (err, result) ->
    if err then throw err else f(result)

# combine async results with key-value objects
U.combine = (N, callback) ->
  n = 0
  obj = {}
  (values) ->
    U.extendDeep(obj, values)
    n++
    if n is N
      return callback(obj)

# very helpful debugging functions
U.inspect = (f) ->
  (args...) ->
    console.log.apply(console, ['in:'].concat(args))
    result = f.apply(null, args)
    console.log('out:', result)
    return result

U.stopwatch = ->
  start = U.timestamp()
  -> (U.timestamp() - start) / 1000

# wrap functions that can fuck up
U.faultTolerant = (f) -> (args...) ->
  try
    f.apply(null, args)
  catch error
    console.error error, error.stack, 'function arguments:', args

# allow an async function to timeout
U.timeoutCallback = (ms, f) ->
  called = false
  id = Meteor.setTimeout ->
    called = true
    f?(null, new Meteor.Error(600, 'Timed out'))
  , ms
  (args...) ->
    unless called
      Meteor.clearTimeout(id)
      f?.apply(null, args)

# a simple event emitter / dispatcher
U.createDispatcher = ->
  listeners = {}
  register = (f) ->
    id = Random.hexString(10)
    listeners[id] = f
    {stop: -> delete listeners[id]}
  dispatch = (x) ->
    for id, f of listeners
      f(R.clone(x))
    return
  reset = ->
    listeners = {}
  return {listeners, register, dispatch, reset}

# debounce all function calls through one debouncer
# which drops function calls when its called too fast.
# very useful to prevent the user from spamming your app
# and breaking animations
U.createDebouncer = (ms) ->
  busy = false
  return (f) ->
    return (args...) =>
      if not busy
        busy = true
        f.apply(this, args)
        U.delay ms, -> busy = false

# a single function
U.debounce = (ms, f) ->
  busy = false
  return (args...) =>
    if not busy
      busy = true
      f.apply(this, args)
      U.delay ms, -> busy = false

# waits for the function to stop being called for some time before
# actually calling it. useful for autocomplete so you don't spam
# your server too much.
U.throttle = (ms, func) ->
  id = null
  return (args...) ->
    Meteor.clearTimeout(id)
    id = U.delay ms, -> func.apply(null, args)

# prefix console.log statements
U.logger = (prefix...) ->
  (args...) -> console.log.apply(console, prefix.concat(args))

U.capitalize = (string) ->
  string.substring(0,1).toUpperCase() + string.substring(1)


# mutably set a value of an object given an array of keys
U.set = R.curry (path, value, object) ->
  [first, rest...] = path
  if rest.length is 0
    object[first] = value
  else
    unless object[first]
      object[first] = {}
    U.set(rest, value, object[first])
  return

# mutably unset / delete a value of an object given an array of keys
U.unset = R.curry (path, object) ->
  [first, rest...] = path
  if rest.length is 0
    delete object[first]
  else
    U.unset(rest, object[first])
    if Object.keys(object[first]).length is 0
      delete object[first]
  return

U.mapObj = (obj, func) ->
  newObj = {}
  for k,v of obj
    newObj[k] = func(k,v,obj)
  return newObj

U.updateWhere = R.curry (pred, func, list) ->
  R.map(
    (elem) -> if pred(elem) then func(elem) else elem
    list
  )

U.defaults = (overrideObj={}, defaultsObj) ->
  override = R.clone(overrideObj)
  _.defaults(override, defaultsObj)
  return override

# pipe functions through this and only the first one will be called
U.once = ->
  called = false
  (f) ->
    unless called
      called = true
      f()
