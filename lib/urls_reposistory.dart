import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addShortenedUrl(longUrl, shortUrl) {
  CollectionReference shorten_urls =
      FirebaseFirestore.instance.collection('shorten_urls');
  // Call the user's CollectionReference to add a new user
  return shorten_urls
      .add({
        'long_url': longUrl, // John Doe
        'short_url': shortUrl, // Stokes and Sons
        'created_at': Timestamp.now()
      })
      .then((value) => print("URL Added"))
      .catchError((error) => print("Failed to add user: $error"));
}
