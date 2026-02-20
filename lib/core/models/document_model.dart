class Document {
  final String id;
  final String name;
  final String status;
  final String type;
  final String url;

  Document({
    required this.id,
    required this.name,
    required this.status,
    required this.type,
    required this.url,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['documentName'] ?? 'Untitled Document',
      status: json['status'] ?? 'N/A',
      type: json['type'] ?? 'GENERAL',
      url: json['url'] ?? '',
    );
  }
}
