import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../models/mortgage_model.dart';
import '../theme/colors.dart';
import '../theme/type.dart';

class MortgageCalculatorScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MortgageCalculatorScreen> createState() => _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends ConsumerState<MortgageCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _homePriceController = TextEditingController(text: '400000');
  final _downPaymentController = TextEditingController(text: '20');
  final _interestRateController = TextEditingController(text: '6.5');
  final _loanTermController = TextEditingController(text: '30');
  final _propertyTaxController = TextEditingController(text: '1.2');
  final _homeInsuranceController = TextEditingController(text: '0.3');
  final _pmiController = TextEditingController(text: '0.5');
  final _hoaFeesController = TextEditingController(text: '0');

  MortgageCalculation? _calculation;
  ClosingCosts? _closingCosts;
  final _currencyFormatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
  final _percentFormatter = NumberFormat.percentPattern();

  @override
  void initState() {
    super.initState();
    _calculateMortgage();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppColors.darkGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              indicator: BoxDecoration(
                color: AppColors.strong,
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.medium,
              labelStyle: AppTypography.detail,
              tabs: [
                Tab(text: 'Calculator'),
                Tab(text: 'Closing Costs'),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildCalculatorTab(),
                _buildClosingCostsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculatorTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Loan Details', style: AppTypography.title02),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _homePriceController,
                      label: 'Home Price',
                      prefix: '\$',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _downPaymentController,
                      label: 'Down Payment',
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _interestRateController,
                      label: 'Interest Rate',
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _loanTermController,
                      label: 'Loan Term',
                      suffix: 'years',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // Additional costs section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Costs (Annual %)', style: AppTypography.title02),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _propertyTaxController,
                      label: 'Property Tax',
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _homeInsuranceController,
                      label: 'Home Insurance',
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _pmiController,
                      label: 'PMI (if down payment < 20%)',
                      suffix: '%',
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 2.h),
                    
                    _buildInputField(
                      controller: _hoaFeesController,
                      label: 'HOA Fees (Monthly)',
                      prefix: '\$',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 2.h),
            
            // Calculate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateMortgage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.strong,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Calculate', style: AppTypography.title02),
              ),
            ),
            
            SizedBox(height: 3.h),
            
            // Results section
            if (_calculation != null) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildClosingCostsTab() {
    if (_closingCosts == null) {
      return Center(
        child: Text(
          'Calculate your mortgage first to see closing costs',
          style: AppTypography.body,
          textAlign: TextAlign.center,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total closing costs
          Card(
            elevation: 2,
            color: AppColors.strong.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text('Estimated Closing Costs', style: AppTypography.title02),
                  SizedBox(height: 1.h),
                  Text(
                    _currencyFormatter.format(_closingCosts!.totalClosingCosts),
                    style: AppTypography.title01.copyWith(color: AppColors.strong),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Closing costs breakdown
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Breakdown', style: AppTypography.title02),
                  SizedBox(height: 2.h),
                  
                  ..._closingCosts!.breakdown.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.5.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(entry.key, style: AppTypography.body),
                          ),
                          Text(
                            _currencyFormatter.format(entry.value),
                            style: AppTypography.body,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 2.h),
          
          // Cash needed at closing
          Card(
            elevation: 2,
            color: AppColors.medium.withOpacity(0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  Text('Total Cash Needed at Closing', style: AppTypography.title02),
                  SizedBox(height: 1.h),
                  Text(
                    _currencyFormatter.format(
                      _calculation!.downPayment + _closingCosts!.totalClosingCosts,
                    ),
                    style: AppTypography.title01.copyWith(color: AppColors.medium),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Down Payment: ${_currencyFormatter.format(_calculation!.downPayment)}\n'
                    'Closing Costs: ${_currencyFormatter.format(_closingCosts!.totalClosingCosts)}',
                    style: AppTypography.detail,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.strong),
        ),
      ),
      onChanged: (value) => _calculateMortgage(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a value';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Payment Breakdown', style: AppTypography.title02),
        SizedBox(height: 2.h),
        
        // Monthly payment summary
        Card(
          elevation: 2,
          color: AppColors.strong.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Text('Total Monthly Payment', style: AppTypography.title02),
                SizedBox(height: 1.h),
                Text(
                  _currencyFormatter.format(_calculation!.monthlyPayment),
                  style: AppTypography.title01.copyWith(color: AppColors.strong),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Payment breakdown
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Breakdown', style: AppTypography.title02),
                SizedBox(height: 2.h),
                
                _buildBreakdownItem(
                  'Principal & Interest',
                  _calculation!.breakdown.principalAndInterest,
                ),
                _buildBreakdownItem(
                  'Property Tax',
                  _calculation!.breakdown.propertyTax,
                ),
                _buildBreakdownItem(
                  'Home Insurance',
                  _calculation!.breakdown.homeInsurance,
                ),
                if (_calculation!.breakdown.pmi > 0)
                  _buildBreakdownItem(
                    'PMI',
                    _calculation!.breakdown.pmi,
                  ),
                if (_calculation!.breakdown.hoaFees > 0)
                  _buildBreakdownItem(
                    'HOA Fees',
                    _calculation!.breakdown.hoaFees,
                  ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 2.h),
        
        // Loan summary
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Loan Summary', style: AppTypography.title02),
                SizedBox(height: 2.h),
                
                _buildSummaryItem('Home Price', _calculation!.homePrice),
                _buildSummaryItem('Down Payment', _calculation!.downPayment),
                _buildSummaryItem('Loan Amount', _calculation!.loanAmount),
                _buildSummaryItem('Total Interest', _calculation!.totalInterest),
                _buildSummaryItem('Total Payment', _calculation!.totalPayment),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownItem(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            _currencyFormatter.format(amount),
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.body),
          Text(
            _currencyFormatter.format(amount),
            style: AppTypography.body,
          ),
        ],
      ),
    );
  }

  void _calculateMortgage() {
    final homePrice = double.tryParse(_homePriceController.text) ?? 0;
    final downPaymentPercent = double.tryParse(_downPaymentController.text) ?? 0;
    final interestRate = double.tryParse(_interestRateController.text) ?? 0;
    final loanTermYears = int.tryParse(_loanTermController.text) ?? 0;
    final propertyTax = (double.tryParse(_propertyTaxController.text) ?? 0) / 100;
    final homeInsurance = (double.tryParse(_homeInsuranceController.text) ?? 0) / 100;
    final pmi = (double.tryParse(_pmiController.text) ?? 0) / 100;
    final hoaFees = double.tryParse(_hoaFeesController.text) ?? 0;

    if (homePrice > 0 && interestRate > 0 && loanTermYears > 0) {
      setState(() {
        _calculation = MortgageCalculation.calculate(
          homePrice: homePrice,
          downPaymentPercent: downPaymentPercent,
          interestRate: interestRate,
          loanTermYears: loanTermYears,
          propertyTax: propertyTax,
          homeInsurance: homeInsurance,
          pmi: pmi,
          hoaFees: hoaFees,
        );
        
        _closingCosts = ClosingCosts(loanAmount: _calculation!.loanAmount);
      });
    }
  }

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
}