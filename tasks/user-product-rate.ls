require! {
  async
  _: underscore

  handle: \../helper/error-handler
  '../helper/collection'.find-to-array
}

exports = module.exports = (db, callback) ->
  err, rates-collection <- db.collection \user-rate
  handle err

  err, users-collection <- db.collection \user
  handle err

  users <- find-to-array users-collection, {}

  uids = _.map users, (user) ->
    user.id

  err <- async.each uids, (uid, callback) ->
    rates <- find-to-array rates-collection, {uid: uid}

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
