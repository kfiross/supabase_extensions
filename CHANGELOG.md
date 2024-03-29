## [1.0.1]
- Fixed bugs with `Supabase.on` migrated code in 1.0.0

## [1.0.0]
- Updated to latest dependencies
- Updated to `supabase` v2 API

## [0.6.2]
- Added `Supabase.jwt` to retrieve accessToken easily

## [0.6.1]
- fixed `Supabase.isLogged` to return `bool`

## [0.6.0+1]
- updated `pub.dev` score

## [0.6.0]
- added `Supabase.isLogged`
- updated `Supabase.on` event parameter from `String` into enum `CrudEvent`
- added ability to listen to `DELETE` events

## [0.5.1]
- Better error handling + updated `pub.dev` score

## [0.5.0]
- Added streams listeners for single database-based event type

## [0.4.0]
- Using now `QueryResults` as return object to the `sql` function

## [0.3.2]
- Added shorter getter to user's ID (`SupabaseClient.uid` instead `SupabaseClient.auth.currentUser.uid`)

## [0.3.1]
- Fixed bug with `SELECT` statements like `..AND field = 'string'`

## [0.3.0]
- Added `INSERT` statement support

## [0.2.1]
- Fixed multiple columns ordering + using `distinct`

## [0.2.0]
- Initial `SELECT` statement support

## [0.1.0]
- Initial version
