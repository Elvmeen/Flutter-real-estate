import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_real_estate/ui/theme/colors.dart';
import 'package:flutter_real_estate/ui/theme/type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';

class MortgageCalculatorScreen extends ConsumerStatefulWidget {
  @override
  _MortgageCalculatorScreenState createState() => _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends ConsumerState<MortgageCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homePriceController = TextEditingController();
  final _downPaymentController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTermController = TextEditingController(text: '30');

  double _monthlyPayment = 0;
  double _totalPayment = 0;
  double _totalInterest = 0;
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
    if (_formKey.currentState!.validate()) {
      final homePrice = double.parse(_homePriceController.text.replaceAll(',', ''));
      final downPayment = double.parse(_downPaymentController.text.replaceAll(',', ''));
      final interestRate = double.parse(_interestRateController.text);
      final loanTerm = int.parse(_loanTermController.text);

      // Calculate loan amount
      final loanAmount = homePrice - downPayment;

      // Calculate monthly interest rate
      final monthlyInterestRate = (interestRate / 100) / 12;

      // Calculate number of payments
      final numberOfPayments = loanTerm * 12;

      // Calculate monthly payment using the formula:
      // M = P [ i(1 + i)^n ] / [ (1 + i)^n – 1]
      final monthlyPayment = loanAmount *
          (monthlyInterestRate * pow(1 + monthlyInterestRate, numberOfPayments)) /
          (pow(1 + monthlyInterestRate, numberOfPayments) - 1);

      // Calculate total payment and interest
      final totalPayment = monthlyPayment * numberOfPayments;
      final totalInterest = totalPayment - loanAmount;

      // Estimate closing costs (typically 2-5% of home price)
      final closingCosts = homePrice * 0.03;

      setState(() {
        _monthlyPayment = monthlyPayment;
        _totalPayment = totalPayment;
        _totalInterest = totalInterest;
        _closingCosts = closingCosts;
      });
    }
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? prefix,
    String? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.title02),
        SizedBox(height: 1.h),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.hint,
            prefixText: prefix,
            suffixText: suffix,
            filled: true,
            fillColor: AppColors.darkGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
          style: AppTypography.input,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a value';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildResultCard({required String label, required double value}) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTypography.detail.copyWith(color: AppColors.medium),
          ),
          SizedBox(height: 0.5.h),
          Text(
            '\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            style: AppTypography.title01.copyWith(fontSize: 20),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mortgage Calculator',
              style: AppTypography.title01,
            ),
            SizedBox(height: 3.h),
            _buildInputField(
              label: 'Home Price',
              controller: _homePriceController,
              hint: '500000',
              prefix: '\$ ',
            ),
            SizedBox(height: 2.h),
            _buildInputField(
              label: 'Down Payment',
              controller: _downPaymentController,
              hint: '100000',
              prefix: '\$ ',
            ),
            SizedBox(height: 2.h),
            _buildInputField(
              label: 'Interest Rate',
              controller: _interestRateController,
              hint: '6.5',
              suffix: ' %',
            ),
            SizedBox(height: 2.h),
            _buildInputField(
              label: 'Loan Term',
              controller: _loanTermController,
              hint: '30',
              suffix: ' years',
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateMortgage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.strong,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Calculate',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (_monthlyPayment > 0) ...[
              SizedBox(height: 3.h),
              Text(
                'Results',
                style: AppTypography.title01,
              ),
              SizedBox(height: 2.h),
              _buildResultCard(
                label: 'Monthly Payment',
                value: _monthlyPayment,
              ),
              SizedBox(height: 2.h),
              _buildResultCard(
                label: 'Total Payment',
                value: _totalPayment,
              ),
              SizedBox(height: 2.h),
              _buildResultCard(
                label: 'Total Interest',
                value: _totalInterest,
              ),
              SizedBox(height: 2.h),
              _buildResultCard(
                label: 'Estimated Closing Costs',
                value: _closingCosts,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
