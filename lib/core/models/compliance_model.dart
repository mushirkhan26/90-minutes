
class Compliance {
  final String id;
  final String title;
  final String description;
  final String status;
  final DateTime dueDate;
  final String? note;
  final List<RequiredDocument> requiredDocuments;
  final List<ActionLink> actionLinks;
  final List<SubmittedDocument> submittedDocuments;

  Compliance({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.dueDate,
    this.note,
    this.requiredDocuments = const [],
    this.actionLinks = const [],
    this.submittedDocuments = const [],
  });

  factory Compliance.fromJson(Map<String, dynamic> json) {
    return Compliance(
      id: json['complianceId'] ?? json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      note: json['note'],
      requiredDocuments: (json['requiredDocuments'] as List?)
              ?.map((i) => RequiredDocument(name: i.toString()))
              .toList() ??
          [],
      actionLinks: (json['actionLinks'] as List?)
              ?.map((i) => ActionLink.fromJson(i))
              .toList() ??
          [],
      submittedDocuments: (json['submittedDocuments'] as List?)
              ?.map((i) => SubmittedDocument(name: i.toString().split('/').last, url: i.toString()))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'dueDate': dueDate.toIso8601String(),
      'note': note,
      'requiredDocuments': requiredDocuments.map((e) => e.name).toList(),
      'actionLinks': actionLinks.map((e) => e.toJson()).toList(),
      'submittedDocuments': submittedDocuments.map((e) => e.url).toList(),
    };
  }
}

class RequiredDocument {
  final String name;

  RequiredDocument({required this.name});
}

class ActionLink {
  final String title;
  final String url;

  ActionLink({required this.title, required this.url});

  factory ActionLink.fromJson(Map<String, dynamic> json) {
    return ActionLink(
      title: json['label'] ?? json['title'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
    };
  }
}

class SubmittedDocument {
  final String name;
  final String url;

  SubmittedDocument({required this.name, required this.url});
}
