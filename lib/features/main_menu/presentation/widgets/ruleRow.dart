import 'package:flutter/material.dart';

class RuleRow extends StatelessWidget {
  final String icon;
  final String text;

  const RuleRow({super.key, required this.icon, required this.text});
  
 
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}