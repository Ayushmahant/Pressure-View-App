import 'package:firebase_core/firebase_core.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/services.dart';
import 'loginscreen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   final List<String> cities = ["New York", "London", "Tokyo", "Berlin", "Paris"];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("City Pressure Monitoring")),
//       body: GridView.builder(
//         padding: EdgeInsets.all(10),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemCount: cities.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => CityPressureScreen(city: cities[index])),
//               );
//             },
//             child: Card(
//               elevation: 5,
//               child: Center(
//                 child: Text(
//                   cities[index],
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class CityPressureScreen extends StatefulWidget {
//   final String city;
//   CityPressureScreen({required this.city});
//
//   @override
//   _CityPressureScreenState createState() => _CityPressureScreenState();
// }
//
// class _CityPressureScreenState extends State<CityPressureScreen> {
//   String pressure = "Fetching...";
//   List<String> history = [];
//   final String awsIotEndpoint = "a2ltpqu5ncbzvt-ats.iot.eu-north-1.amazonaws.com";
//   late MqttServerClient client;
//   final String topic = "myDevice/data";
//
//   @override
//   void initState() {
//     super.initState();
//     connectToAWSIoT();
//   }
//
//   Future<void> connectToAWSIoT() async {
//     client = MqttServerClient.withPort(awsIotEndpoint, 'flutter_client', 8883);
//     client.secure = true;
//     client.logging(on: true);
//     client.keepAlivePeriod = 20;
//
//     try {
//       final rootCA = await rootBundle.load('assets/certs/rootCA.pem');
//       final deviceCert = await rootBundle.load('assets/certs/cert.pem');
//       final privateKey = await rootBundle.load('assets/certs/privateKey.pem');
//
//       SecurityContext context = SecurityContext.defaultContext;
//       context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());
//       context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
//       context.usePrivateKeyBytes(privateKey.buffer.asUint8List());
//
//       client.securityContext = context;
//       client.connectionMessage = MqttConnectMessage()
//           .withClientIdentifier("flutter_client")
//           .startClean()
//           .withWillQos(MqttQos.atMostOnce);
//
//       await client.connect();
//
//       if (client.connectionStatus!.state == MqttConnectionState.connected) {
//         client.subscribe(topic, MqttQos.atMostOnce);
//
//         client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
//           final MqttPublishMessage receivedMessage = messages.first.payload as MqttPublishMessage;
//           final String payload = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);
//
//           try {
//             final data = jsonDecode(payload);
//             setState(() {
//               pressure = data['pressure']?.toString() ?? "N/A";
//               if (history.length >= 10) history.removeAt(0);
//               history.add(pressure);
//             });
//           } catch (e) {
//             print("JSON Decode Error: $e");
//           }
//         });
//       }
//     } catch (e) {
//       print("Connection Error: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     client.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Pressure Data - ${widget.city}")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text("Current Pressure: $pressure", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   builder: (context) => Padding(
//                     padding: EdgeInsets.all(10),
//                     child: ListView(
//                       children: history.reversed.map((e) => ListTile(title: Text("Pressure: $e"))).toList(),
//                     ),
//                   ),
//                 );
//               },
//               child: Text("View History"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
