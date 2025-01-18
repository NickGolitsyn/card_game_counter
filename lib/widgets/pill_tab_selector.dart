import 'package:flutter/cupertino.dart';

class PillTabSelector extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final Function(String) onOptionSelected;
  final double height;
  final double fontSize;

  const PillTabSelector({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
    this.height = 40,
    this.fontSize = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(height / 2),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: options.map((option) {
          final isSelected = option == selectedOption;
          return Expanded(
            child: GestureDetector(
              onTap: () => onOptionSelected(option),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? CupertinoColors.activeBlue : null,
                  borderRadius: BorderRadius.circular((height - 4) / 2),
                ),
                child: Center(
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? CupertinoColors.white : CupertinoColors.black,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
} 