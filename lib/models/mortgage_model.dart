// Mortgage calculation model
class MortgageCalculation {
  final double principal;
  final double annualInterestRate;
  final int loanTermYears;
  final double downPayment;
  final double propertyTax;
  final double homeInsurance;
  final double pmi;
  final double hoaFees;
  final double closingCosts;

  MortgageCalculation({
    required this.principal,
    required this.annualInterestRate,
    required this.loanTermYears,
    this.downPayment = 0,
    this.propertyTax = 0,
    this.homeInsurance = 0,
    this.pmi = 0,
    this.hoaFees = 0,
    this.closingCosts = 0,
  });

  // Calculate monthly mortgage payment
  double get monthlyPayment {
    if (annualInterestRate == 0) {
      return principal / (loanTermYears * 12);
    }
    
    final monthlyRate = annualInterestRate / 100 / 12;
    final numberOfPayments = loanTermYears * 12;
    
    return principal * 
           (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
           (pow(1 + monthlyRate, numberOfPayments) - 1);
  }

  // Calculate total monthly payment including taxes, insurance, etc.
  double get totalMonthlyPayment {
    return monthlyPayment + 
           (propertyTax / 12) + 
           (homeInsurance / 12) + 
           pmi + 
           hoaFees;
  }

  // Calculate total interest paid over loan term
  double get totalInterest {
    return (monthlyPayment * loanTermYears * 12) - principal;
  }

  // Calculate total amount paid over loan term
  double get totalAmount {
    return monthlyPayment * loanTermYears * 12;
  }

  // Calculate loan-to-value ratio
  double get loanToValueRatio {
    return (principal / (principal + downPayment)) * 100;
  }

  // Calculate equity percentage
  double get equityPercentage {
    return (downPayment / (principal + downPayment)) * 100;
  }

  // Calculate affordability based on income
  static double calculateAffordablePrice({
    required double annualIncome,
    required double annualInterestRate,
    required int loanTermYears,
    required double downPaymentPercentage,
    double debtToIncomeRatio = 0.28,
  }) {
    final monthlyIncome = annualIncome / 12;
    final maxMonthlyPayment = monthlyIncome * debtToIncomeRatio;
    
    if (annualInterestRate == 0) {
      return (maxMonthlyPayment * loanTermYears * 12) / (1 - downPaymentPercentage / 100);
    }
    
    final monthlyRate = annualInterestRate / 100 / 12;
    final numberOfPayments = loanTermYears * 12;
    
    final maxPrincipal = maxMonthlyPayment * 
                        (pow(1 + monthlyRate, numberOfPayments) - 1) /
                        (monthlyRate * pow(1 + monthlyRate, numberOfPayments));
    
    return maxPrincipal / (1 - downPaymentPercentage / 100);
  }

  // Calculate down payment amount
  static double calculateDownPayment({
    required double homePrice,
    required double downPaymentPercentage,
  }) {
    return homePrice * (downPaymentPercentage / 100);
  }

  // Calculate closing costs (typically 2-5% of home price)
  static double calculateClosingCosts({
    required double homePrice,
    double closingCostPercentage = 3.0,
  }) {
    return homePrice * (closingCostPercentage / 100);
  }

  Map<String, dynamic> toJson() {
    return {
      'principal': principal,
      'annualInterestRate': annualInterestRate,
      'loanTermYears': loanTermYears,
      'downPayment': downPayment,
      'propertyTax': propertyTax,
      'homeInsurance': homeInsurance,
      'pmi': pmi,
      'hoaFees': hoaFees,
      'closingCosts': closingCosts,
    };
  }

  factory MortgageCalculation.fromJson(Map<String, dynamic> json) {
    return MortgageCalculation(
      principal: json['principal'].toDouble(),
      annualInterestRate: json['annualInterestRate'].toDouble(),
      loanTermYears: json['loanTermYears'],
      downPayment: json['downPayment']?.toDouble() ?? 0,
      propertyTax: json['propertyTax']?.toDouble() ?? 0,
      homeInsurance: json['homeInsurance']?.toDouble() ?? 0,
      pmi: json['pmi']?.toDouble() ?? 0,
      hoaFees: json['hoaFees']?.toDouble() ?? 0,
      closingCosts: json['closingCosts']?.toDouble() ?? 0,
    );
  }
}

// Import dart:math for pow function
import 'dart:math';