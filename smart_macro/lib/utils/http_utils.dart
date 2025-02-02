import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart'; // Import for MediaType


/** IP address of the OCR service */
const SERVER_URL = "http://34.219.112.199:5000";

const OCR_URL = "http://34.219.112.199:5000/upload";

int generateRandomId() {
  final math.Random random = math.Random();
  int Id = random.nextInt(900000) + 100000; // Generates a number between 100000 and 999999
  return Id;
}


Future<Map<String, dynamic>> getProfileMacros(Map<String, dynamic> requestBody) async {
  try {
    log(jsonEncode(requestBody).toString());
    final response = await http.post(
      Uri.parse('$SERVER_URL/user'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',  // Indicate that you want JSON back
      },
      body: jsonEncode(requestBody),
    );

    log(response.statusCode.toString());
    if (response.statusCode == 200) {
      log("Server response:");
      log(json.decode(response.body).toString());
      return json.decode(response.body);
    } else {
      log("Code: ${response.statusCode} : ${json.decode(response.body).toString()}");
      throw Exception("${response.statusCode} : ${response.body}");
    }
  } catch (error) {
    rethrow;
  }
}


/// Sends an HTTP POST request for OCR processing to the server
///
/// @param imageBytes  The image data to be sent for OCR processing
/// @param additionalParams  Additional parameters to include in the request
///
/// @return response object with status code and message
///      200: OCR processing was successful.
///      400: The request was malformed or invalid.
///      500: Internal server error - an unexpected error occurred on the server
///      Throws error if the request cannot be sent
///
Future<Map<String, dynamic>> sendOcrData(XFile image, String userId) async {
  try {
    // Create the JSON object
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(OCR_URL),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        image.path,
        contentType: MediaType('image', 'png'),
      ),
    );

    request.fields['userId'] = userId; // Example field
    request.fields['receiptId'] = generateRandomId().toString(); // Another example field

    final response = await http.Response.fromStream(await request.send());
  
    log("Received");
    // Handle the response
    if (response.statusCode == 200) {
      log("Server response: ${response.body}");
      return json.decode(response.body);
    } else {
      log("Error: ${response.statusCode} : ${response.body}");
      throw Exception("Failed to send image");
    }
  } catch (error) {
    log("ERROR: $error");
    rethrow;
  }
}



Future<Map<String, dynamic>> getReceiptsFromAWS(Map<String, dynamic> requestBody) async {
  try {
    log(jsonEncode(requestBody).toString());
    final response = await http.get(
      Uri.parse('$SERVER_URL/get_receipt'),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      log("Server response:");
      log(json.decode(response.body).toString());
      return json.decode(response.body);
    } else {
      log("Code: ${response.statusCode} : ${json.decode(response.body).toString()}");
      throw Exception("${response.statusCode} : ${response.body}");
    }
  } catch (error) {
    rethrow;
  }
}

Future<Map<String, dynamic>> getPantryFromAWS(Map<String, dynamic> requestBody) async {
  try {
    log(jsonEncode(requestBody).toString());
    final response = await http.post(
      Uri.parse('$SERVER_URL/pantry'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );
    if (response.statusCode == 200) {
      log("Server response:");
      log(json.decode(response.body).toString());
      return json.decode(response.body);
    } else {
      log("Code: ${response.statusCode} : ${json.decode(response.body).toString()}");
      throw Exception("${response.statusCode} : ${response.body}");
    }
  } catch (error) {
    rethrow;
  }
}

