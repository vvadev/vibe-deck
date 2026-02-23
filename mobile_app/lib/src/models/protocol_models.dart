class ProtocolMessage {
  ProtocolMessage({required this.type, required this.payload});

  final String type;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {'type': type, 'payload': payload};

  factory ProtocolMessage.fromJson(Map<String, dynamic> json) {
    return ProtocolMessage(
      type: (json['type'] ?? '').toString(),
      payload: (json['payload'] ?? <String, dynamic>{}) as Map<String, dynamic>,
    );
  }
}

class DiscoveredHost {
  DiscoveredHost({
    required this.name,
    required this.address,
    required this.wsPort,
  });

  final String name;
  final String address;
  final int wsPort;

  String get endpoint => '$address:$wsPort';
}
