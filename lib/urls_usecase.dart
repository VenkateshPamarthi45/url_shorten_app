import 'dart:io';

import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> shortenUrl(longUrl) async {
  var token = "XXXXXXXXXXXXXXXXXXXXX";
  final response = await http.post(
      Uri.parse('https://api-ssl.bitly.com/v4/shorten'),
      body: jsonEncode({"long_url": longUrl, "domain": "bit.ly"}),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json'
      });
  final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
  return responseJson['link'];
}
