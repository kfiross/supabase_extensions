## 0.5.0
- Added streams listeners for single database-based event type

## 0.4.0
- Using now `QueryResults` as return object to the `sql` function

## 0.3.2
- Added shorter getter to user's ID (`SupabaseClient.uid` instead `SupabaseClient.auth.currentUser.uid`)

## 0.3.1
- Fixed bug with `SELECT` statements like `..AND field = 'string'`

## 0.3.0
- Added `INSERT` statement support

## 0.2.1
- Fixed multiple columns ordering + using `distinct`

## 0.2.0
- Initial version, initial `SELECT` statement support
