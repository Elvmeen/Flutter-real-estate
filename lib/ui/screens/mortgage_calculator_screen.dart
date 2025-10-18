import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MortgageCalculatorScreen extends StatefulWidget {
  const MortgageCalculatorScreen({super.key});

  @override
  State<MortgageCalculatorScreen> createState() => _MortgageCalculatorScreenState();
}

class _MortgageCalculatorScreenState extends State<MortgageCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController(text: '500000');
  final _downCtrl = TextEditingController(text: '100000');
  final _rateCtrl = TextEditingController(text: '6.5');
  final _termCtrl = TextEditingController(text: '30');
  final _taxPctCtrl = TextEditingController(text: '1.2');
  final _insMonthlyCtrl = TextEditingController(text: '100');
  final _hoaMonthlyCtrl = TextEditingController(text: '0');
  final _closingPctCtrl = TextEditingController(text: '2.0');

  final _fmt = NumberFormat.currency(symbol: '\$');

  num? monthlyPI;
  num? monthlyTaxes;
  num? monthlyTotal;
  num? closingCost;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mortgage Calculator')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _numField('Home price', _priceCtrl),
            _numField('Down payment', _downCtrl),
            _numField('Interest rate (%)', _rateCtrl),
            _numField('Term (years)', _termCtrl),
            const Divider(),
            _numField('Property tax (%/yr)', _taxPctCtrl),
            _numField('Insurance (monthly)', _insMonthlyCtrl),
            _numField('HOA (monthly)', _hoaMonthlyCtrl),
            _numField('Closing cost (% of price)', _closingPctCtrl),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _calculate, child: const Text('Calculate')),
            const SizedBox(height: 16),
            if (monthlyPI != null) ...[
              _resultRow('Monthly P&I', _fmt.format(monthlyPI)),
              _resultRow('Monthly taxes', _fmt.format(monthlyTaxes)),
              _resultRow('Estimated total monthly', _fmt.format(monthlyTotal)),
              _resultRow('Estimated closing costs', _fmt.format(closingCost)),
            ]
          ],
        ),
      ),
    );
  }

  Widget _numField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), Text(value)],
      ),
    );
  }

  void _calculate() {
    final price = num.tryParse(_priceCtrl.text) ?? 0;
    final down = num.tryParse(_downCtrl.text) ?? 0;
    final ratePct = num.tryParse(_rateCtrl.text) ?? 0;
    final years = num.tryParse(_termCtrl.text) ?? 0;
    final taxPct = num.tryParse(_taxPctCtrl.text) ?? 0;
    final insMonthly = num.tryParse(_insMonthlyCtrl.text) ?? 0;
    final hoaMonthly = num.tryParse(_hoaMonthlyCtrl.text) ?? 0;
    final closingPct = num.tryParse(_closingPctCtrl.text) ?? 0;

    final principal = (price - down).clamp(0, double.infinity);
    final monthlyRate = ratePct / 100 / 12;
    final n = years * 12;

    num m;
    if (monthlyRate == 0 || n == 0) {
      m = n == 0 ? 0 : principal / n;
    } else {
      final factor = powPower(1 + monthlyRate, n);
      m = principal * (monthlyRate * factor) / (factor - 1);
    }

    final taxesMonthly = price * (taxPct / 100) / 12;
    final totalMonthly = m + taxesMonthly + insMonthly + hoaMonthly;
    final closing = price * (closingPct / 100);

    setState(() {
      monthlyPI = m;
      monthlyTaxes = taxesMonthly;
      monthlyTotal = totalMonthly;
      closingCost = closing;
    });
  }

  num powPower(num base, num exp) {
    num result = 1;
    for (var i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }
}
