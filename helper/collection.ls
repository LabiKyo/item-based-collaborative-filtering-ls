require! {
  handle: \../helper/error-handler
}

exports.find-to-array = (collection, query, callback) ->
  err, cursor <- collection.find query
  handle err
  err, doc <- cursor.to-array!
  handle err
  callback doc
