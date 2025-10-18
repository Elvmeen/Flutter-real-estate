import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:sizer/sizer.dart';

class MortgageCalculatorScreen extends StatefulWidget {
  @override
  _MortgageCalculatorScreenState createState() => _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends State<MortgageCalculatorScreen> {
  final _homePriceController = TextEditingController();
  final _downPaymentController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTermController = TextEditingController(text: '30');

  double _monthlyPayment = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;
  double _loanAmount = 0;
  double _closingCosts = 0;

  @override
  void dispose() {
    _homePriceController.dispose();
    _downPaymentController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    super.dispose();
  }

  void _calculateMortgage() {
    final homePrice = double.tryParse(_homePriceController.text.replaceAll(',', '')) ?? 0;
    final downPayment = double.tryParse(_downPaymentController.text.replaceAll(',', '')) ?? 0;
    final interestRate = double.tryParse(_interestRateController.text) ?? 0;
    final loanTerm = int.tryParse(_loanTermController.text) ?? 30;

    if (homePrice > 0 && interestRate > 0) {
      _loanAmount = homePrice - downPayment;
      _closingCosts = homePrice * 0.03; // Estimate 3% closing costs

      if (_loanAmount > 0) {
        final monthlyRate = interestRate / 100 / 12;
        final numberOfPayments = loanTerm * 12;

        // Calculate monthly payment using mortgage formula
        _monthlyPayment = _loanAmount *
            (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
            (pow(1 + monthlyRate, numberOfPayments) - 1);

        _totalPayment = _monthlyPayment * numberOfPayments;
        _totalInterest = _totalPayment - _loanAmount;
      } else {
        _monthlyPayment = 0;
        _totalPayment = 0;
        _totalInterest = 0;
      }

      setState(() {});
    }
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calculate Your Mortgage',
              style: AppTypography.title01,
            ),
            SizedBox(height: 1.h),
            Text(
              'Estimate your monthly mortgage payments',
              style: AppTypography.body.copyWith(color: AppColors.medium),
            ),
            SizedBox(height: 3.h),
            // Home Price
            _buildInputField(
              label: 'Home Price',
              controller: _homePriceController,
              prefix: '\$',
              hint: '500,000',
            ),
            SizedBox(height: 2.h),
            // Down Payment
            _buildInputField(
              label: 'Down Payment',
              controller: _downPaymentController,
              prefix: '\$',
              hint: '100,000',
            ),
            SizedBox(height: 2.h),
            // Interest Rate
            _buildInputField(
              label: 'Interest Rate',
              controller: _interestRateController,
              suffix: '%',
              hint: '3.5',
              isDecimal: true,
            ),
            SizedBox(height: 2.h),
            // Loan Term
            _buildInputField(
              label: 'Loan Term',
              controller: _loanTermController,
              suffix: 'years',
              hint: '30',
            ),
            SizedBox(height: 3.h),
            // Calculate Button
            ElevatedButton(
              onPressed: _calculateMortgage,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.strong,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Calculate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 3.h),
            // Results
            if (_monthlyPayment > 0) ...[
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Monthly Payment',
                      style: AppTypography.body.copyWith(color: AppColors.medium),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _formatCurrency(_monthlyPayment),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.strong,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              _buildResultCard('Loan Amount', _loanAmount),
              SizedBox(height: 1.h),
              _buildResultCard('Total Payment', _totalPayment),
              SizedBox(height: 1.h),
              _buildResultCard('Total Interest', _totalInterest),
              SizedBox(height: 1.h),
              _buildResultCard('Estimated Closing Costs', _closingCosts),
              SizedBox(height: 3.h),
              // Payment Breakdown
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Breakdown',
                      style: AppTypography.title02,
                    ),
                    SizedBox(height: 2.h),
                    _buildBreakdownBar(
                      'Principal & Interest',
                      _monthlyPayment,
                      AppColors.strong,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      '* This calculator provides estimates. Actual payments may include property taxes, insurance, and HOA fees.',
                      style: AppTypography.detail.copyWith(
                        color: AppColors.medium,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
    String? hint,
    bool isDecimal = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.title02,
        ),
        SizedBox(height: 1.h),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                isDecimal ? RegExp(r'[\d.]') : RegExp(r'[\d,]'),
              ),
            ],
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTypography.hint,
              prefixText: prefix != null ? '$prefix ' : null,
              suffixText: suffix != null ? ' $suffix' : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(String label, double amount) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.body,
          ),
          Text(
            _formatCurrency(amount),
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownBar(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body),
            Text(
              _formatCurrency(amount),
              style: AppTypography.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
