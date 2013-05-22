require! {
  handle: \../helper/error-handler
}

exports = module.exports = (db, callback) ->
  (err, rates) <- db.collection \user-rate
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

  (err, average-rate) <- rates.map-reduce map, reduce, out: {replace: 'user-average-rate'}, finalize: finalize
  handle err
  callback err, average-rate
