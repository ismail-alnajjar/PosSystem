import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class QzTrayService {
  WebSocketChannel? _channel;
  // final String _url = 'ws://localhost:8182'; // Dynamically determined now
  
  // Stream controller to handle responses
  final _responseController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onMessage => _responseController.stream;

  // Connect to QZ Tray
  Future<bool> connect() async {
    try {
      // Determine correct host
      String host = 'localhost';
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          // 10.0.2.2 is the special IP for Android Emulator to access the Host PC
          host = '10.0.2.2';
        }
      }
      
      final url = 'ws://$host:8182';
      print("Attempting to connect to QZ Tray at: $url");

      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channel!.stream.listen((message) {
        try {
          final data = jsonDecode(message);
          _responseController.add(data);
          print("QZ Response: $message");
        } catch (e) {
          print("Error parsing QZ message: $e");
        }
      }, onError: (error) {
        print("QZ Connection Error: $error");
      });

      // Give it a moment to connect
      await Future.delayed(const Duration(seconds: 1));
      return true;
    } catch (e) {
      print("Failed to connect to QZ Tray: $e");
      return false;
    }
  }

  // Find all printers
  void findPrinters() {
    // QZ Tray 2.x format for finding printers
    // Note: usages of QZ Tray without the official JS library over raw WebSockets
    // require constructing the exact JSON message.
    // This is a simplified attempts matching typical QZ 2.0 calls.
    
    // Often getting the list is done via:
    // { "method": "findPrinters", "params": [query, signature, signingTimestamp] }
    // Or simpler for public usage.
    
    // Using a generic message structure often accepted by the QZ WebSocket handler:
    final msg = {
      "call": "printers.find",
      "params": {
        "query": null // null to find all
      },
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "uid": "flutter_${DateTime.now().millisecondsSinceEpoch}"
    };
    
    _send(msg);
  }

  // Print HTML Receipt
  void printHtmlReceipt(String printerName, String htmlContent) {
    // Construct the print config and data
    final msg = {
      "call": "print",
      "params": {
        "printer": {
          "name": printerName
        },
        "options": {
          "jobName": "POS Receipt ${DateTime.now()}"
        },
        "data": [
          {
            "type": "pixel",
            "format": "html",
            "flavor": "plain",
            "data": htmlContent
          }
        ]
      },
      "timestamp": DateTime.now().millisecondsSinceEpoch,
      "uid": "flutter_${DateTime.now().millisecondsSinceEpoch}"
    };

    _send(msg);
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null) {
      final jsonStr = jsonEncode(data);
      print("Sending to QZ: $jsonStr");
      _channel!.sink.add(jsonStr);
    } else {
      print("QZ Tray not connected");
    }
  }

  void dispose() {
    _channel?.sink.close();
    _responseController.close();
  }
}
