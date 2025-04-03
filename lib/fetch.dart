import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter/services.dart';


class PressureDataScreen extends StatefulWidget {
  @override
  _PressureDataScreenState createState() => _PressureDataScreenState();
}

class _PressureDataScreenState extends State<PressureDataScreen> {
  String pressure = "Waiting for data...";
  String time = "Waiting for data...";
  final String awsIotEndpoint = "a2ltpqu5ncbzvt-ats.iot.eu-north-1.amazonaws.com";
  final String topic = "myDevice/data";
  late MqttServerClient client;
  bool isConnected = false;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();
    connectToAWSIoT();
  }

  Future<void> connectToAWSIoT() async {
    if (isConnected || isConnecting) {
      print("🔄 Already connected or connecting...");
      return;
    }

    setState(() => isConnecting = true);
    client = MqttServerClient.withPort(awsIotEndpoint, 'flutter_client', 8883);
    client.secure = true;
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = (String topic) => print("📡 Subscribed to: $topic");

    try {
      final rootCA = await rootBundle.load('assets/certs/rootCA.pem');
      final deviceCert = await rootBundle.load('assets/certs/cert.pem');
      final privateKey = await rootBundle.load('assets/certs/privateKey.pem');

      SecurityContext context = SecurityContext.defaultContext;
      context.setTrustedCertificatesBytes(rootCA.buffer.asUint8List());
      context.useCertificateChainBytes(deviceCert.buffer.asUint8List());
      context.usePrivateKeyBytes(privateKey.buffer.asUint8List());

      client.securityContext = context;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier("flutter_client")
          .startClean()
          .withWillQos(MqttQos.atMostOnce);
      client.connectionMessage = connMessage;

      print("🔄 Connecting to AWS IoT...");
      await client.connect();

      if (client.connectionStatus == null) {
        print("❌ Connection Status is NULL");
        disconnectFromAWSIoT();
        return;
      }

      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        print("✅ Connected to AWS IoT");
        setState(() {
          isConnected = true;
          isConnecting = false;
        });

        client.subscribe(topic, MqttQos.atMostOnce);

        client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>> messages) {
          print("📩 Received ${messages.length} message(s)");

          for (var message in messages) {
            final MqttPublishMessage receivedMessage = message.payload as MqttPublishMessage;
            final String payload = MqttPublishPayload.bytesToStringAsString(receivedMessage.payload.message);

            print("📩 [AWS IoT] Raw MQTT Message: $payload");

            try {
              final data = jsonDecode(payload);
              print("📊 Parsed Data -> Pressure: ${data['pressure']}, Time: ${data['time']}");

              if (mounted) {
                setState(() {
                  pressure = data['pressure']?.toString() ?? "N/A";
                  time = data['time']?.toString() ?? "N/A";
                });
              }
            } catch (e) {
              print("❌ JSON Decode Error: $e");
            }
          }
        });
      } else {
        print("❌ Connection Failed: ${client.connectionStatus!.state}");
        disconnectFromAWSIoT();
      }
    } catch (e) {
      print("❌ Connection Error: $e");
      disconnectFromAWSIoT();
    } finally {
      if (mounted) {
        setState(() => isConnecting = false);
      }
    }
  }

  void onConnected() {
    print("🟢 MQTT Connected!");
    if (mounted) {
      setState(() => isConnected = true);
    }
  }

  void onDisconnected() {
    print("🔴 MQTT Disconnected!");
    if (mounted) {
      setState(() => isConnected = false);
    }
  }

  Future<void> disconnectFromAWSIoT() async {
    if (!isConnected) {
      print("🔹 Already disconnected.");
      return;
    }

    try {
      print("🔌 Disconnecting from AWS IoT...");
      client.unsubscribe(topic);
      client.disconnect();
      print("✅ Successfully Disconnected!");
    } catch (e) {
      print("❌ Error during disconnection: $e");
    } finally {
      if (mounted) {
        setState(() {
          isConnected = false;
          pressure = "Waiting for data...";
          time = "Waiting for data...";
        });
      }
    }
  }

  @override
  void dispose() {
    disconnectFromAWSIoT();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("AWS IoT Pressure Data")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Pressure: $pressure", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Time: $time", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: isConnecting ? null : connectToAWSIoT,
              child: Text(isConnecting ? "Connecting..." : "Reconnect"),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: disconnectFromAWSIoT,
              child: Text("Disconnect"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
