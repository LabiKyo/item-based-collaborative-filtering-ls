require! {
  fs
  child_process

  async
  mongodb
  mongodb.Db
  mongodb.Server

  \./tasks/product-average
  \./tasks/user-average
  handle: \./helper/error-handler
}

server = new Server \localhost, 27017, {native_parser: true}
db = new Db \ibcf, server, {safe: true}

# tasks
task \import:db, "Import data from json files", ->
  file-db-mapping = do
    favorite: \favorite
    product: \product
    user: \user
    user_rate: \user-rate


  (err) <- async.each <[favorite product user user_rate]>, (file, callback) ->
    cmd = "mongoimport -d ibcf -c #{file-db-mapping[file]} --drop --jsonArray ./data/#file.json"
    (err, stdout, stderr) <- child_process.exec cmd
    if err
      console.log "[error:#file] #err"
    callback err
  handle err

task \init:db, "Initialize database", ->
  (err, db) <- db.open
  handle err

  (err) <- async.each <[favorite product user user-rate]>, (collection, callback) ->
    db.ensure-index collection, {id: 1}, {unique: true, background: true, dropDups: true}, callback
  handle err

  <- user-average db
  handle err
  <- product-average db
  handle err
  db.close!

task \update:user:average, "Calculate each users' average rate", ->
  (err, db) <- db.open
  handle err

  <- user-average db
  db.close!

task \update:product:average, "Calculate each products' average rate", ->
  (err, db) <- db.open
  handle err

  <- product-average db
  db.close!
