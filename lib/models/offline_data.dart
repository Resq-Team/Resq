class OfflineData {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final String syncStatus;

  OfflineData({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    required this.syncStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'syncStatus': syncStatus,
    };
  }

  factory OfflineData.fromMap(Map<dynamic, dynamic> map) {
    return OfflineData(
      id: map['id'] as String,
      type: map['type'] as String,
      data: Map<String, dynamic>.from(map['data']),
      createdAt: DateTime.parse(map['createdAt'] as String),
      syncStatus: map['syncStatus'] as String,
    );
  }
}