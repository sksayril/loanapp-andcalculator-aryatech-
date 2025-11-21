class LoanProfile {
  final int? id;
  final String loanSector;
  final String loanCompany;
  final double totalAmount;
  final double monthlyEmi;
  final int tenureDays;
  final DateTime createdAt;

  LoanProfile({
    this.id,
    required this.loanSector,
    required this.loanCompany,
    required this.totalAmount,
    required this.monthlyEmi,
    required this.tenureDays,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'loan_sector': loanSector,
      'loan_company': loanCompany,
      'total_amount': totalAmount,
      'monthly_emi': monthlyEmi,
      'tenure_days': tenureDays,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory LoanProfile.fromMap(Map<String, dynamic> map) {
    return LoanProfile(
      id: map['id'] as int?,
      loanSector: map['loan_sector'] as String,
      loanCompany: map['loan_company'] as String,
      totalAmount: map['total_amount'] as double,
      monthlyEmi: map['monthly_emi'] as double,
      tenureDays: map['tenure_days'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  double get remainingAmount {
    // Calculate remaining amount based on EMI paid (simplified calculation)
    return totalAmount; // This can be enhanced later
  }

  int get daysRemaining {
    return tenureDays; // This can be enhanced based on current date
  }
}

