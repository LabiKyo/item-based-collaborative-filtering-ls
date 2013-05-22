require! {
  async

  handle: \../helper/error-handler
}

exports = module.exports = (db, callback) ->
  (err, rates) <- db.collection \user-rate
  handle err

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

  (err, average-rate-collection) <- rates.map-reduce map, reduce, out: {replace: 'product-average-rate'}, finalize: finalize
  handle err

  # add average rate into product collection
  err, rates-cursor <- average-rate-collection.find {}
  handle err
  err, rates <- rates-cursor.to-array!
  handle err

  err, product-collection <- db.collection \product
  handle err

  err, results <- async.map rates, (rate, callback) ->
    err, doc <- product-collection.find-and-modify do
      * id: rate._id
      * [[\id, 1]]
      * $set: 'average-rate': rate.value
      * new: true
    callback err, doc
  handle err
  callback err
