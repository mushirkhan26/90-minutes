class PayrollModel {
  final String? employeeId;
  final String? packageName;
  final double? basicSalary;
  final double? allowances;
  final double? bonus;
  final double? grossSalary;
  final double? providentFund;
  final double? tax;
  final double? netSalary;
  final String? lastUpdated;
  final String? month;
  final String? year;

  PayrollModel({
    this.employeeId,
    this.packageName,
    this.basicSalary,
    this.allowances,
    this.bonus,
    this.grossSalary,
    this.providentFund,
    this.tax,
    this.netSalary,
    this.lastUpdated,
    this.month,
    this.year,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json, {String? employeeId}) {
    double toDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    final details = json['packageDetails'] as Map<String, dynamic>? ?? {};

    return PayrollModel(
      employeeId: employeeId ?? json['employeeId']?.toString(),
      packageName: details['packageName']?.toString(),
      basicSalary: toDouble(details['baseSalary']),
      allowances: toDouble(details['allowances']),
      bonus: toDouble(details['bonus']),
      grossSalary: toDouble(details['grossSalary']),
      providentFund: toDouble(details['providentFund']?['pfAmount']),
      tax: toDouble(details['tax']?['taxAmount']),
      netSalary: toDouble(details['netSalary']),
      lastUpdated: details['lastUpdated']?.toString(),
      month: json['month']?.toString() ?? json['month'],
      year: json['year']?.toString() ?? json['year'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'packageName': packageName,
      'basicSalary': basicSalary,
      'allowances': allowances,
      'bonus': bonus,
      'grossSalary': grossSalary,
      'providentFund': providentFund,
      'tax': tax,
      'netSalary': netSalary,
      'lastUpdated': lastUpdated,
      'month': month,
      'year': year,
    };
  }

  PayrollModel copyWith({
    String? employeeId,
    String? packageName,
    double? basicSalary,
    double? allowances,
    double? bonus,
    double? grossSalary,
    double? providentFund,
    double? tax,
    double? netSalary,
    String? lastUpdated,
    String? month,
    String? year,
  }) {
    return PayrollModel(
      employeeId: employeeId ?? this.employeeId,
      packageName: packageName ?? this.packageName,
      basicSalary: basicSalary ?? this.basicSalary,
      allowances: allowances ?? this.allowances,
      bonus: bonus ?? this.bonus,
      grossSalary: grossSalary ?? this.grossSalary,
      providentFund: providentFund ?? this.providentFund,
      tax: tax ?? this.tax,
      netSalary: netSalary ?? this.netSalary,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }
}
