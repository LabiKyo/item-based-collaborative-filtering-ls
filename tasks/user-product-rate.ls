require! {
  async
  _: underscore

  handle: \../helper/error-handler
}

exports = module.exports = (db, callback) ->
  err, rates-collection <- db.collection \user-rate
  handle err

  err, users-collection <- db.collection \user
  handle err

  err, users-cursor <- users-collection.find {}
  handle err

  err, users <- users-cursor.to-array!
  handle err

  uids = _.map users, (user) ->
    user.id

  err <- async.each uids, (uid, callback) ->
    err, rates-cursor <- rates-collection.find {uid: uid}
    handle err
    err, rates <- rates-cursor.to-array!
    handle err

    rates = _ rates
      .map (rate) ->
        return "#{rate.pid}": rate.rate
      .reduce (memo, rate) ->
        memo <<< rate
      , {}

    err, doc <- users-collection.find-and-modify do
      * id: uid
      * [[\id 1]]
      * $set: rates: rates
      * new: true
    callback err
  handle err

  callback err
