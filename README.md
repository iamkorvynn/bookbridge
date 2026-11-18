# BookBridge

Campus textbook exchange for students. List a textbook you no longer
need, browse what seniors are selling, and contact the seller directly
on WhatsApp — no middleman, no commission.

## Features

- **List a textbook** — title, author (optional), subject/stream, price
  in ₹, condition (Like New / Good / Fair / Heavily Used), a photo from
  the camera or gallery, and your name + phone number. Photos are copied
  into the app's own documents directory, so a listing keeps working
  even if the original gallery photo is deleted.
- **Browse** — every listing with photo, title, price and a colour-coded
  condition badge.
- **Search & filter** — search by title, author or subject; filter by
  subject and by condition; hide sold books.
- **Sort** — newest first, price low → high, price high → low.
- **Book details** — big photo, full info, and one-tap contact:
  **WhatsApp** opens a `wa.me` deep link with a prefilled message
  ("Hi! Is \<title\> still available on BookBridge?") and **Call**
  opens the dialler. Indian 10-digit numbers are automatically
  prefixed with 91.
- **Mark as sold** — a sold book stays visible with a SOLD badge
  (or in the sold section of My listings) and can be marked available
  again.
- **My listings** — all your books, available first, then sold, with
  delete (removes the listing and its stored photo).
- **First-run onboarding** — a short walkthrough of list → browse →
  contact on WhatsApp.
- **Starts empty** — no fake listings, no sample books. All data is
  yours, stored locally on your device in SQLite. No account, no
  server, no tracking.

## Tech

- Flutter 3.50 / Dart 3.14, Material 3, Android only
- `sqflite` — local listings + onboarding flag
- `image_picker` + `path_provider` — photos stored in the app
  documents directory
- `url_launcher` — WhatsApp (`wa.me`) and `tel:` deep links

## Build & run

```sh
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
```

## Project structure

```
lib/
  main.dart                  # app entry, first-run onboarding gate
  models/listing.dart        # Listing model, conditions, subjects
  services/
    database_helper.dart     # SQLite CRUD + onboarding flag
    contact_links.dart       # phone normalisation, wa.me / tel: links
    listing_filter.dart      # search / filter / sort (pure functions)
    photo_service.dart       # pick + store listing photos
  screens/
    onboarding_screen.dart   # first-run walkthrough
    home_screen.dart         # browse, search, filters, sort
    add_listing_screen.dart  # listing form with validation
    listing_detail_screen.dart
    my_listings_screen.dart
  widgets/
    listing_card.dart
    condition_badge.dart
```

## License

MIT — see [LICENSE](LICENSE).
