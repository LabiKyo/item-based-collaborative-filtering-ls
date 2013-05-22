require! {
  fs
  child_process

  async
  mongodb
  mongodb.Db
  mongodb.Server

  \./tasks/product-average
  \./tasks/user-average
}

server = new Server \localhost, 27017, {native_parser: true}
db = new Db \ibcf, server, {safe: true}

# tasks
task \import:db, "Import data from json files", ->
  file-db-mapping = do
    favorite: \favorite
    products: \products
    user: \user
    user_rate: \user-rate


  async.each <[favorite products user user_rate]>, (file, callback) ->
    cmd = "mongoimport -d ibcf -c #{file-db-mapping[file]} --drop --jsonArray ./data/#file.json"
    (err, stdout, stderr) <- child_process.exec cmd
    if err
      console.log "[error:#file] #err"
    callback err
  , (err) ->
    if err
      throw err

task \init:db, "Initialize database", ->
  (err, db) <- db.open
  async.each <[favorite products user user-rate]>, (collection, callback) ->
    db.ensure-index collection, {id: 1}, {unique: true, background: true, dropDups: true}, callback
  , (err) ->
    if err
      throw err
    db.close!

task \update:user:average, "Calculate each user's average rate", ->
  (err, db) <- db.open
  if err
    throw err

  <- user-average db
  db.close!

task \update:product:average, "Calculate each products's average rate", ->
  (err, db) <- db.open
  if err
    throw err

  <- product-average db
  db.close!
