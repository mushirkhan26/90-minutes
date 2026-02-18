class BenefitsClaimModel {
  final String id;
  final String employeeId;
  final String beneficiaryName;
  final String relationWithEmployee;
  final String email;
  final String hospitalName;
  final String propertyAddress;
  final String incidentDate;
  final String damageDescription;
  final String treatmentDate;
  final String providerName;
  final String receipt;
  final String expenseDescription;
  final String expenseDate;
  final String expenseAmount;
  final String? causeOfDeath;
  final String nomineeName;
  final String? deathCertificate;
  final String dentalBills;
  final String dentistName;
  final String admissionDate;
  final String dischargeDate;
  final String vehicleNumber;
  final String accidentDate;
  final String claimAmount;
  final String billAmount;
  final String benefitName;
  final String hospitalBill;
  final String prescription;
  final String repairEstimate;
  final String repairBills;
  final String policeReport;
  final String insuranceId;
  final String claimStatus;
  final String? reasonForRejection;
  final List<BankDetails> bankDetails;

  BenefitsClaimModel({
    required this.id,
    required this.employeeId,
    required this.beneficiaryName,
    required this.relationWithEmployee,
    required this.email,
    required this.hospitalName,
    required this.propertyAddress,
    required this.incidentDate,
    required this.damageDescription,
    required this.treatmentDate,
    required this.providerName,
    required this.receipt,
    required this.expenseDescription,
    required this.expenseDate,
    required this.expenseAmount,
    this.causeOfDeath,
    required this.nomineeName,
    this.deathCertificate,
    required this.dentalBills,
    required this.dentistName,
    required this.admissionDate,
    required this.dischargeDate,
    required this.vehicleNumber,
    required this.accidentDate,
    required this.claimAmount,
    required this.billAmount,
    required this.benefitName,
    required this.hospitalBill,
    required this.prescription,
    required this.repairEstimate,
    required this.repairBills,
    required this.policeReport,
    required this.insuranceId,
    required this.claimStatus,
    this.reasonForRejection,
    required this.bankDetails,
  });

  factory BenefitsClaimModel.fromJson(Map<String, dynamic> json) {
    return BenefitsClaimModel(
      id: json['_id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      beneficiaryName: json['beneficiaryName'] ?? '',
      relationWithEmployee: json['relationWithEmployee'] ?? '',
      email: json['email'] ?? '',
      hospitalName: json['hospitalName'] ?? '',
      propertyAddress: json['propertyAddress'] ?? '',
      incidentDate: json['incidentDate'] ?? '',
      damageDescription: json['damageDescription'] ?? '',
      treatmentDate: json['treatmentDate'] ?? '',
      providerName: json['providerName'] ?? '',
      receipt: json['receipt'] ?? '',
      expenseDescription: json['expenseDescription'] ?? '',
      expenseDate: json['expenseDate'] ?? '',
      expenseAmount: json['expenseAmount'] ?? '',
      causeOfDeath: json['causeOfDeath'],
      nomineeName: json['nomineeName'] ?? '',
      deathCertificate: json['deathCertificate'],
      dentalBills: json['dentalBills'] ?? '',
      dentistName: json['dentistName'] ?? '',
      admissionDate: json['admissionDate'] ?? '',
      dischargeDate: json['dischargeDate'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      accidentDate: json['accidentDate'] ?? '',
      claimAmount: json['claimAmount'] ?? '',
      billAmount: json['billAmount'] ?? '',
      benefitName: json['benefitName'] ?? '',
      hospitalBill: json['hospitalBill'] ?? '',
      prescription: json['prescription'] ?? '',
      repairEstimate: json['repairEstimate'] ?? '',
      repairBills: json['repairBills'] ?? '',
      policeReport: json['policeReport'] ?? '',
      insuranceId: json['insuranceId'] ?? '',
      claimStatus: json['claimStatus'] ?? '',
      reasonForRejection: json['reasonForRejection'],
      bankDetails: (json['bankDetails'] as List<dynamic>?)
              ?.map((e) => BankDetails.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'employeeId': employeeId,
      'beneficiaryName': beneficiaryName,
      'relationWithEmployee': relationWithEmployee,
      'email': email,
      'hospitalName': hospitalName,
      'propertyAddress': propertyAddress,
      'incidentDate': incidentDate,
      'damageDescription': damageDescription,
      'treatmentDate': treatmentDate,
      'providerName': providerName,
      'receipt': receipt,
      'expenseDescription': expenseDescription,
      'expenseDate': expenseDate,
      'expenseAmount': expenseAmount,
      'causeOfDeath': causeOfDeath,
      'nomineeName': nomineeName,
      'deathCertificate': deathCertificate,
      'dentalBills': dentalBills,
      'dentistName': dentistName,
      'admissionDate': admissionDate,
      'dischargeDate': dischargeDate,
      'vehicleNumber': vehicleNumber,
      'accidentDate': accidentDate,
      'claimAmount': claimAmount,
      'billAmount': billAmount,
      'benefitName': benefitName,
      'hospitalBill': hospitalBill,
      'prescription': prescription,
      'repairEstimate': repairEstimate,
      'repairBills': repairBills,
      'policeReport': policeReport,
      'insuranceId': insuranceId,
      'claimStatus': claimStatus,
      'reasonForRejection': reasonForRejection,
      'bankDetails': bankDetails.map((e) => e.toJson()).toList(),
    };
  }

  BenefitsClaimModel copyWith({
    String? claimStatus,
  }) {
    return BenefitsClaimModel(
      id: id,
      employeeId: employeeId,
      beneficiaryName: beneficiaryName,
      relationWithEmployee: relationWithEmployee,
      email: email,
      hospitalName: hospitalName,
      propertyAddress: propertyAddress,
      incidentDate: incidentDate,
      damageDescription: damageDescription,
      treatmentDate: treatmentDate,
      providerName: providerName,
      receipt: receipt,
      expenseDescription: expenseDescription,
      expenseDate: expenseDate,
      expenseAmount: expenseAmount,
      causeOfDeath: causeOfDeath,
      nomineeName: nomineeName,
      deathCertificate: deathCertificate,
      dentalBills: dentalBills,
      dentistName: dentistName,
      admissionDate: admissionDate,
      dischargeDate: dischargeDate,
      vehicleNumber: vehicleNumber,
      accidentDate: accidentDate,
      claimAmount: claimAmount,
      billAmount: billAmount,
      benefitName: benefitName,
      hospitalBill: hospitalBill,
      prescription: prescription,
      repairEstimate: repairEstimate,
      repairBills: repairBills,
      policeReport: policeReport,
      insuranceId: insuranceId,
      claimStatus: claimStatus ?? this.claimStatus,
      reasonForRejection: reasonForRejection,
      bankDetails: bankDetails,
    );
  }
}

class BankDetails {
  final String bankName;
  final String accountHolderName;
  final String ifscCode;
  final String accountNumber;
  final String accountType;

  BankDetails({
    required this.bankName,
    required this.accountHolderName,
    required this.ifscCode,
    required this.accountNumber,
    required this.accountType,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) {
    return BankDetails(
      bankName: json['bankName'] ?? '',
      accountHolderName: json['accountHolderName'] ?? '',
      ifscCode: json['ifscCode'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      accountType: json['accountType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'ifscCode': ifscCode,
      'accountNumber': accountNumber,
      'accountType': accountType,
    };
  }
}