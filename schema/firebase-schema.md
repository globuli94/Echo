# Echo — Firestore Schema

**Single source of truth.** All agents must read this document before reading or writing Firestore documents.

---

## Collections

### `users`

**Path:** `users/{uid}`
**Purpose:** Stores user profile data. Document is created on first successful sign-in. The document ID equals the Firebase Auth UID.
**Owner:** Authenticated user whose UID matches the document ID.

| Field | Firestore Type | Required | Description |
|---|---|---|---|
| `uid` | string | required | Firebase Auth UID; mirrors the document ID |
| `displayName` | string | required | Human-readable name shown in the UI |
| `username` | string | required | Unique handle used for @-mentions and profile URLs |
| `bio` | string | optional | Short user biography (may be empty string) |
| `avatarUrl` | string | optional | HTTPS URL to the user's avatar stored in Firebase Storage |
| `followerCount` | number | required | Cached count of followers; default 0 |
| `followingCount` | number | required | Cached count of accounts the user follows; default 0 |
| `postCount` | number | required | Cached count of posts created by the user; default 0 |
| `createdAt` | timestamp | required | Server timestamp set when the document is first created |

**Access patterns:**
- Authenticated user reads own profile (`users/{uid}`, owner) — single-document (get)
- Authenticated user reads any other user's profile (`users/{uid}`, third party) — single-document (get)
- Authenticated user lists user documents filtered by `displayName` prefix (user search) — multi-document (list); covered by `allow read: if request.auth != null`
- Authenticated user creates own document on first sign-in (uid == auth.uid)
- Authenticated user updates own profile fields (`displayName`, `bio`, `avatarUrl`)
- Any authenticated user updates `followerCount` or `followingCount` on any user document (third-party field-scoped write, FieldValue.increment)

**Query patterns:**
- Filter `username == value` (no sort) — username search; no composite index required
- Filter `displayName >= query` AND `displayName < query + '\uF8FF'`, sort by `displayName ASC` — displayName prefix search (user search screen); covered by composite index on `users(displayName ASC)` in `firestore.indexes.json`

---

### `posts`

**Path:** `posts/{postId}`
**Purpose:** Stores individual text-based posts created by users. The document ID is a Firestore auto-generated ID.
**Owner:** Authenticated user whose UID matches the `authorId` field.

| Field | Firestore Type | Required | Description |
|---|---|---|---|
| `postId` | string | required | Mirrors the Firestore document ID |
| `authorId` | string | required | Firebase Auth UID of the user who created this post |
| `content` | string | required | Text body of the post |
| `likeCount` | number | required | Cached count of likes; default 0 |
| `commentCount` | number | required | Cached count of comments; default 0 |
| `createdAt` | timestamp | required | Server timestamp set when the post is first created |
| `imageUrl` | string | optional | HTTPS URL to the post image stored in Firebase Storage; omitted when no image |

**Access patterns:**
- Authenticated user reads any post (`posts/{postId}`, third party)
- Authenticated user creates a post (authorId must equal auth.uid)
- Author deletes own post (`posts/{postId}`, owner)
- Authenticated user updates `likeCount` on any post (third-party field-scoped write)

**Query patterns:**
- No filter, sort by `createdAt DESC` — full feed; no composite index required
- Filter `authorId == uid`, sort by `createdAt DESC` — profile page posts; **composite index required** (see `firestore.indexes.json`)

---

### `users/{uid}/following/{targetUid}`

**Path:** `users/{followerId}/following/{targetUid}`
**Purpose:** Records that `followerId` follows `targetUid`. Document ID equals the followed user's UID, enabling O(1) "am I following this user?" lookup. Written atomically alongside incrementing `followerCount` on the target and `followingCount` on the follower.
**Owner:** Authenticated user whose UID matches the `followerId` path segment.

| Field | Firestore Type | Required | Description |
|---|---|---|---|
| `followedAt` | timestamp | required | Server timestamp set when the follow relationship is created |
| `targetUid` | string | required | UID of the user being followed; mirrors the document ID |

**Access patterns:**
- Authenticated user creates their own follow document (`followerId == auth.uid`)
- Authenticated user deletes their own follow document (`followerId == auth.uid`)
- Any authenticated user reads a following subcollection document (e.g. to check if a follow relationship exists)
- Any authenticated user lists all documents in a user's following subcollection (FollowingScreen)
- Any authenticated user queries the `following` collection group filtering `targetUid == uid` to retrieve all followers of a user (FollowersScreen)

**Query patterns:**
- Fetch all documents from `users/{uid}/following` (no filter, no sort) — retrieve full following list to build feed; no composite index required
- Collection group query on `following` filtering `targetUid == uid` — retrieve all followers of a user (FollowersScreen); Firestore automatically maintains a COLLECTION_GROUP single-field index on `targetUid`; no explicit composite index entry required in `firestore.indexes.json`

---

## Firebase Storage Paths

| Path | Purpose | Owner | Access |
|---|---|---|---|
| `avatars/{userId}` | Avatar image for the user at `userId` | Authenticated user whose UID matches `userId` | Owner can write (upload/overwrite); any authenticated user can read |
| `posts/{uid}/{postId}` | Image attached to a post | Authenticated user whose UID matches path segment `uid` | Owner can write (upload); any authenticated user can read |

---

## Firebase Services

| Service | Purpose |
|---|---|
| Firebase Authentication | Gate all Firestore read/write rules; provides `request.auth` context |
| Cloud Firestore | Primary database for all user and post data |
| Firebase Storage | Avatar image uploads referenced by `users.avatarUrl`; post image uploads referenced by `posts.imageUrl` |

## Authentication Providers

Firebase Authentication is enabled on project `echo-9cf94` with the following providers:

| Provider | Status | Notes |
|---|---|---|
| Email/Password | Enabled | Standard email + password sign-up and sign-in |
| Google Sign-In | Enabled | OAuth 2.0; iOS client ID `608728058117-v506ssdksim6qrq7b9nbf1t5ku64rjns.apps.googleusercontent.com` |

iOS OAuth configuration:
- `GIDClientID` in `ios/Runner/Info.plist`: `608728058117-v506ssdksim6qrq7b9nbf1t5ku64rjns.apps.googleusercontent.com`
- `REVERSED_CLIENT_ID` URL scheme in `ios/Runner/Info.plist`: `com.googleusercontent.apps.608728058117-v506ssdksim6qrq7b9nbf1t5ku64rjns`

---

## Change Log

| Date | Classification | Description |
|---|---|---|
| 2026-05-22 | Safe | Initial schema — `users` and `posts` collections created |
| 2026-05-23 | Safe | Firebase Authentication enabled — Email/Password and Google Sign-In providers; iOS OAuth settings configured |
| 2026-05-23 | Safe | SOCAA-402: Storage Paths section added documenting `avatars/{userId}`; `firestore.rules` update rule for `users` scoped to allowed fields (`displayName`, `bio`, `avatarUrl`) |
| 2026-05-23 | Safe | SOCAA-408: `imageUrl` optional field added to `posts` collection; `posts/{uid}/{postId}` Storage path added |
| 2026-05-23 | Safe | SOCAA-417: `users/{uid}/following/{targetUid}` subcollection added with `followedAt` and `targetUid` fields; `users` update rule expanded to allow any authenticated user to increment `followerCount` or `followingCount`; composite index for `posts(authorId, createdAt)` confirmed present |
| 2026-05-23 | Safe | SOCAA-420: Collection group read rule added for `following` (FollowersScreen); COLLECTION_GROUP index on `following.targetUid` added to `firestore.indexes.json`; access and query patterns updated in schema doc |
| 2026-05-23 | Safe | SOCAA-424: `users` collection list access pattern added for `displayName` prefix search; composite index on `users(displayName ASC)` added to `firestore.indexes.json`; existing `allow read: if request.auth != null` rule confirmed to cover list operations |
