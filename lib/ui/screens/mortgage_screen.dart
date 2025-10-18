import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

final mortgageInputProvider = StateProvider<MortgageInput>((ref) => MortgageInput());

class MortgageInput {
  final double price;
  final double downPayment;
  final double annualRate;
  final int years;

  MortgageInput({
    this.price = 300000,
    this.downPayment = 60000,
    this.annualRate = 6.5,
    this.years = 30,
  });

  MortgageInput copyWith({double? price, double? downPayment, double? annualRate, int? years}) {
    return MortgageInput(
      price: price ?? this.price,
      downPayment: downPayment ?? this.downPayment,
      annualRate: annualRate ?? this.annualRate,
      years: years ?? this.years,
    );
  }
}

class MortgageScreen extends ConsumerWidget {
  const MortgageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final input = ref.watch(mortgageInputProvider);
    final principal = (input.price - input.downPayment).clamp(0, double.infinity);
    final monthlyRate = input.annualRate / 100 / 12;
    final n = input.years * 12;
    final monthly = monthlyRate == 0
        ? (principal / n)
        : (principal * monthlyRate) /
            (1 - math.pow(1 + monthlyRate, -n).toDouble());

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Mortgage Calculator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _numField(context, 'Home price', input.price, (v) => _update(ref, input.copyWith(price: v))),
            _numField(context, 'Down payment', input.downPayment, (v) => _update(ref, input.copyWith(downPayment: v))),
            _numField(context, 'Interest rate %', input.annualRate, (v) => _update(ref, input.copyWith(annualRate: v))),
            _intField(context, 'Term (years)', input.years, (v) => _updateYears(ref, input.copyWith(years: v))),
            const SizedBox(height: 24),
            Text('Estimated monthly payment: ${monthly.isFinite ? monthly.toStringAsFixed(2) : '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _numField(BuildContext context, String label, double value, void Function(double) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: value.toStringAsFixed(0),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: (s) => onChanged(double.tryParse(s) ?? value),
    );
  }

  Widget _intField(BuildContext context, String label, int value, void Function(int) onChanged) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: value.toString(),
      keyboardType: TextInputType.number,
      onChanged: (s) => onChanged(int.tryParse(s) ?? value),
    );
  }

  void _update(WidgetRef ref, MortgageInput next) {
    ref.read(mortgageInputProvider.notifier).state = next;
  }

  void _updateYears(WidgetRef ref, MortgageInput next) {
    ref.read(mortgageInputProvider.notifier).state = next;
  }
}
// Using dart:math pow above; no custom power implementation needed.
