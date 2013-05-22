exports = module.exports = (db, callback) ->
  (err, rates) <- db.collection \user-rate
  if err
    throw err

  map = ->
    emit @pid, rate: @rate, user: 1
  reduce = (key, values) ->
    rate = 0
    user = 0
    values.for-each (value) ->
      rate += value.rate
      user += value.user
    return rate: rate, user: user
  finalize = (key, value) ->
    return value.rate / value.user

  (err, average-rate) <- rates.map-reduce map, reduce, out: {replace: 'product-average-rate'}, finalize: finalize
  if err
    throw err
  callback err, average-rate
