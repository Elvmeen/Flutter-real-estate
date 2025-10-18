import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../models/mortgage_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class MortgageCalculatorScreen extends StatefulWidget {
  const MortgageCalculatorScreen({super.key});

  @override
  State<MortgageCalculatorScreen> createState() => _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends State<MortgageCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homePriceController = TextEditingController();
  final _downPaymentController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTermController = TextEditingController();
  final _propertyTaxController = TextEditingController();
  final _homeInsuranceController = TextEditingController();
  final _pmiController = TextEditingController();
  final _hoaFeesController = TextEditingController();

  MortgageCalculation? _calculation;
  bool _showDetailedBreakdown = false;

  @override
  void dispose() {
    _homePriceController.dispose();
    _downPaymentController.dispose();
    _interestRateController.dispose();
    _loanTermController.dispose();
    _propertyTaxController.dispose();
    _homeInsuranceController.dispose();
    _pmiController.dispose();
    _hoaFeesController.dispose();
    super.dispose();
  }

  void _calculateMortgage() {
    if (_formKey.currentState!.validate()) {
      final homePrice = double.parse(_homePriceController.text);
      final downPaymentPercentage = double.parse(_downPaymentController.text);
      final interestRate = double.parse(_interestRateController.text);
      final loanTerm = int.parse(_loanTermController.text);
      
      final downPayment = MortgageCalculation.calculateDownPayment(
        homePrice: homePrice,
        downPaymentPercentage: downPaymentPercentage,
      );
      
      final principal = homePrice - downPayment;
      
      final calculation = MortgageCalculation(
        principal: principal,
        annualInterestRate: interestRate,
        loanTermYears: loanTerm,
        downPayment: downPayment,
        propertyTax: double.tryParse(_propertyTaxController.text) ?? 0,
        homeInsurance: double.tryParse(_homeInsuranceController.text) ?? 0,
        pmi: double.tryParse(_pmiController.text) ?? 0,
        hoaFees: double.tryParse(_hoaFeesController.text) ?? 0,
        closingCosts: MortgageCalculation.calculateClosingCosts(homePrice: homePrice),
      );

      setState(() {
        _calculation = calculation;
        _showDetailedBreakdown = true;
      });
    }
  }

  void _clearForm() {
    _formKey.currentState!.reset();
    _homePriceController.clear();
    _downPaymentController.clear();
    _interestRateController.clear();
    _loanTermController.clear();
    _propertyTaxController.clear();
    _homeInsuranceController.clear();
    _pmiController.clear();
    _hoaFeesController.clear();
    setState(() {
      _calculation = null;
      _showDetailedBreakdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mortgage Calculator'),
        backgroundColor: AppColors.strong,
        foregroundColor: AppColors.white,
        actions: [
          TextButton(
            onPressed: _clearForm,
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              _buildInputField(
                controller: _homePriceController,
                label: 'Home Price',
                prefix: '\$',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter home price';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),
              
              _buildInputField(
                controller: _downPaymentController,
                label: 'Down Payment (%)',
                suffix: '%',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter down payment percentage';
                  }
                  final percentage = double.tryParse(value);
                  if (percentage == null || percentage < 0 || percentage > 100) {
                    return 'Please enter a valid percentage (0-100)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              _buildInputField(
                controller: _interestRateController,
                label: 'Interest Rate (%)',
                suffix: '%',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter interest rate';
                  }
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 50) {
                    return 'Please enter a valid interest rate';
                  }
                  return null;
                },
              ),
              SizedBox(height: 2.h),

              _buildInputField(
                controller: _loanTermController,
                label: 'Loan Term (Years)',
                suffix: 'years',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter loan term';
                  }
                  final term = int.tryParse(value);
                  if (term == null || term <= 0 || term > 50) {
                    return 'Please enter a valid loan term';
                  }
                  return null;
                },
              ),
              SizedBox(height: 3.h),

              // Additional Costs
              _buildSectionTitle('Additional Costs (Optional)'),
              _buildInputField(
                controller: _propertyTaxController,
                label: 'Annual Property Tax',
                prefix: '\$',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),

              _buildInputField(
                controller: _homeInsuranceController,
                label: 'Annual Home Insurance',
                prefix: '\$',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),

              _buildInputField(
                controller: _pmiController,
                label: 'Monthly PMI',
                prefix: '\$',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 2.h),

              _buildInputField(
                controller: _hoaFeesController,
                label: 'Monthly HOA Fees',
                prefix: '\$',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 4.h),

              // Calculate Button
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: _calculateMortgage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.strong,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Calculate Mortgage',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 3.h),

              // Results
              if (_calculation != null) ...[
                _buildResultsSection(),
                SizedBox(height: 2.h),
                _buildDetailedBreakdown(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Text(
        title,
        style: AppTypography.title02.copyWith(
          color: AppColors.strong,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: keyboardType == TextInputType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.strong),
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Payment Breakdown',
            style: AppTypography.title02.copyWith(
              color: AppColors.strong,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildResultRow('Principal & Interest', _formatCurrency(_calculation!.monthlyPayment)),
          _buildResultRow('Property Tax', _formatCurrency(_calculation!.propertyTax / 12)),
          _buildResultRow('Home Insurance', _formatCurrency(_calculation!.homeInsurance / 12)),
          _buildResultRow('PMI', _formatCurrency(_calculation!.pmi)),
          _buildResultRow('HOA Fees', _formatCurrency(_calculation!.hoaFees)),
          const Divider(),
          _buildResultRow(
            'Total Monthly Payment',
            _formatCurrency(_calculation!.totalMonthlyPayment),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal 
                ? AppTypography.title02.copyWith(fontWeight: FontWeight.bold)
                : AppTypography.body,
          ),
          Text(
            value,
            style: isTotal 
                ? AppTypography.title02.copyWith(
                    color: AppColors.strong,
                    fontWeight: FontWeight.bold,
                  )
                : AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedBreakdown() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Loan Summary',
            style: AppTypography.title02.copyWith(
              color: AppColors.strong,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          _buildSummaryRow('Loan Amount', _formatCurrency(_calculation!.principal)),
          _buildSummaryRow('Down Payment', _formatCurrency(_calculation!.downPayment)),
          _buildSummaryRow('Total Interest', _formatCurrency(_calculation!.totalInterest)),
          _buildSummaryRow('Total Amount Paid', _formatCurrency(_calculation!.totalAmount)),
          _buildSummaryRow('Closing Costs', _formatCurrency(_calculation!.closingCosts)),
          _buildSummaryRow('Loan-to-Value Ratio', '${_calculation!.loanToValueRatio.toStringAsFixed(1)}%'),
          _buildSummaryRow('Equity Percentage', '${_calculation!.equityPercentage.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            value,
            style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}