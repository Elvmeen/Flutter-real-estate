import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/strings.dart';
import '../theme/type.dart';

class MortgageScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<MortgageScreen> createState() => _MortgageScreenState();
}

class _MortgageScreenState extends ConsumerState<MortgageScreen> {
  final _priceController = TextEditingController(text: '350000');
  final _downController = TextEditingController(text: '20');
  final _rateController = TextEditingController(text: '6.5');
  final _termController = TextEditingController(text: '30');

  double? _monthly;
  double? _closing;

  void _calculate() {
    final price = double.tryParse(_priceController.text) ?? 0.0;
    final downPct = (double.tryParse(_downController.text) ?? 0.0) / 100.0;
    final ratePct = (double.tryParse(_rateController.text) ?? 0.0) / 100.0;
    final termYears = int.tryParse(_termController.text) ?? 30;

    final principal = price * (1 - downPct);
    final monthlyRate = ratePct / 12.0;
    final n = termYears * 12;

    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = principal / n;
    } else {
      final base = 1 + monthlyRate;
      final denom = 1 - 1 / math.pow(base, n);
      monthlyPayment = principal * monthlyRate / denom;
    }

    // Rough estimate: 3% closing costs on price
    final closingCosts = price * 0.03;

    setState(() {
      _monthly = monthlyPayment;
      _closing = closingCosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Strings.mortgageTitle, style: AppTypography.title02),
          const SizedBox(height: 16),
          _numberField(Strings.mortgagePrice, _priceController),
          _numberField(Strings.mortgageDownPayment, _downController),
          _numberField(Strings.mortgageInterestRate, _rateController),
          _numberField(Strings.mortgageTermYears, _termController),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _calculate,
              child: const Text(Strings.mortgageCalculate),
            ),
          ),
          const SizedBox(height: 16),
          if (_monthly != null)
            Text('${Strings.mortgageMonthlyPayment}: ${_monthly!.toStringAsFixed(2)}',
                style: AppTypography.body),
          if (_closing != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text('${Strings.mortgageClosingCosts}: ${_closing!.toStringAsFixed(2)}',
                  style: AppTypography.body),
            ),
        ],
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
