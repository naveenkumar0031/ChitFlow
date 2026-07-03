import 'package:flutter/material.dart';
import '../models/chit_model.dart';

class ChitCard extends StatelessWidget {
  final ChitModel chit;
  final VoidCallback onTap;

  const ChitCard({super.key, required this.chit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(child: Icon(Icons.groups)),
        title: Text(chit.chitName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Amount: ₹${chit.totalAmount.toStringAsFixed(0)}  |  Members: ${chit.totalMembers}  |  Months: ${chit.totalMonths}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
