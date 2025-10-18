class MortgageCalculation {
  final double homePrice;
  final double downPayment;
  final double loanAmount;
  final double interestRate;
  final int loanTermYears;
  final double monthlyPayment;
  final double totalInterest;
  final double totalPayment;
  final MortgageBreakdown breakdown;

  MortgageCalculation({
    required this.homePrice,
    required this.downPayment,
    required this.loanAmount,
    required this.interestRate,
    required this.loanTermYears,
    required this.monthlyPayment,
    required this.totalInterest,
    required this.totalPayment,
    required this.breakdown,
  });

  factory MortgageCalculation.calculate({
    required double homePrice,
    required double downPaymentPercent,
    required double interestRate,
    required int loanTermYears,
    double propertyTax = 0.012, // 1.2% annually
    double homeInsurance = 0.003, // 0.3% annually
    double pmi = 0.005, // 0.5% annually if down payment < 20%
    double hoaFees = 0, // Monthly HOA fees
  }) {
    final downPayment = homePrice * (downPaymentPercent / 100);
    final loanAmount = homePrice - downPayment;
    final monthlyRate = interestRate / 100 / 12;
    final numberOfPayments = loanTermYears * 12;

    // Calculate monthly principal and interest
    final monthlyPI = loanAmount * 
        (monthlyRate * Math.pow(1 + monthlyRate, numberOfPayments)) / 
        (Math.pow(1 + monthlyRate, numberOfPayments) - 1);

    // Calculate other monthly costs
    final monthlyPropertyTax = (homePrice * propertyTax) / 12;
    final monthlyInsurance = (homePrice * homeInsurance) / 12;
    final monthlyPMI = downPaymentPercent < 20 ? (loanAmount * pmi) / 12 : 0;

    final totalMonthlyPayment = monthlyPI + monthlyPropertyTax + 
        monthlyInsurance + monthlyPMI + hoaFees;

    final totalPayment = monthlyPI * numberOfPayments;
    final totalInterest = totalPayment - loanAmount;

    final breakdown = MortgageBreakdown(
      principalAndInterest: monthlyPI,
      propertyTax: monthlyPropertyTax,
      homeInsurance: monthlyInsurance,
      pmi: monthlyPMI,
      hoaFees: hoaFees,
    );

    return MortgageCalculation(
      homePrice: homePrice,
      downPayment: downPayment,
      loanAmount: loanAmount,
      interestRate: interestRate,
      loanTermYears: loanTermYears,
      monthlyPayment: totalMonthlyPayment,
      totalInterest: totalInterest,
      totalPayment: totalPayment,
      breakdown: breakdown,
    );
  }
}

class MortgageBreakdown {
  final double principalAndInterest;
  final double propertyTax;
  final double homeInsurance;
  final double pmi;
  final double hoaFees;

  MortgageBreakdown({
    required this.principalAndInterest,
    required this.propertyTax,
    required this.homeInsurance,
    required this.pmi,
    required this.hoaFees,
  });

  double get total => principalAndInterest + propertyTax + homeInsurance + pmi + hoaFees;
}

class ClosingCosts {
  final double loanAmount;
  final double originationFee;
  final double appraisalFee;
  final double inspectionFee;
  final double titleInsurance;
  final double recordingFees;
  final double attorneyFees;
  final double surveyFee;
  final double creditReportFee;
  final double prepaidInterest;
  final double prepaidTaxes;
  final double prepaidInsurance;

  ClosingCosts({
    required this.loanAmount,
    this.originationFee = 0.005, // 0.5% of loan amount
    this.appraisalFee = 500,
    this.inspectionFee = 400,
    this.titleInsurance = 0.002, // 0.2% of loan amount
    this.recordingFees = 200,
    this.attorneyFees = 800,
    this.surveyFee = 350,
    this.creditReportFee = 50,
    this.prepaidInterest = 1000,
    this.prepaidTaxes = 2000,
    this.prepaidInsurance = 1200,
  });

  double get totalClosingCosts {
    return (loanAmount * originationFee) +
        appraisalFee +
        inspectionFee +
        (loanAmount * titleInsurance) +
        recordingFees +
        attorneyFees +
        surveyFee +
        creditReportFee +
        prepaidInterest +
        prepaidTaxes +
        prepaidInsurance;
  }

  Map<String, double> get breakdown {
    return {
      'Origination Fee': loanAmount * originationFee,
      'Appraisal Fee': appraisalFee,
      'Home Inspection': inspectionFee,
      'Title Insurance': loanAmount * titleInsurance,
      'Recording Fees': recordingFees,
      'Attorney Fees': attorneyFees,
      'Survey Fee': surveyFee,
      'Credit Report': creditReportFee,
      'Prepaid Interest': prepaidInterest,
      'Prepaid Taxes': prepaidTaxes,
      'Prepaid Insurance': prepaidInsurance,
    };
  }
}

import 'dart:math' as Math;