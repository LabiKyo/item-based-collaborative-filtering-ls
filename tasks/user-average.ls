require! {
  async

  handle: \../helper/error-handler
}

exports = module.exports = (db, callback) ->
  err, rates-collection <- db.collection \user-rate
  handle err

  map = ->
    emit @uid, rate: @rate, product: 1
  reduce = (key, values) ->
    rate = 0
    product = 0
    values.for-each (value) ->
      rate += value.rate
      product += value.product
    return rate: rate, product: product
  finalize = (key, value) ->
    return value.rate / value.product

  err, average-rate-collection <- rates-collection.map-reduce map, reduce, out: {replace: 'user-average-rate'}, finalize: finalize
  handle err

  # add average rate into user collection
  err, rates-cursor <- average-rate-collection.find {}
  handle err
  err, rates <- rates-cursor.to-array!
  handle err

  err, user-collection <- db.collection \user
  handle err

  err, results <- async.map rates, (rate, callback) ->
    err, doc <- user-collection.find-and-modify do
      * id: rate._id
      * [[\id, 1]]
      * $set: 'average-rate': rate.value
      * new: true
    callback err, doc
  handle err
  callback err
