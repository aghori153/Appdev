# Campus Lost & Found

Assignment 3 - CSE-450 Application Development for Mobile Devices

Flutter app connected to Cloud Firestore where students can post lost or found items, browse them and mark them as claimed.

## Features

- Live list of items from the `items` collection
- Search by title and filter by status
- Add item form
- Mark as Claimed using a Firestore transaction
- Delete item
- Detail screen that updates live

## Running

```
flutter pub get
flutter run
```

The `items` collection is seeded on first launch if it is empty.
