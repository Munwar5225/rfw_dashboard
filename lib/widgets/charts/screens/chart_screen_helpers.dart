import 'package:flutter/material.dart';
import '../../../models/chart_config_v2.dart';

Widget buildTabSelector(List<ChartTabV2> tabs, int selected, void Function(int) onSelect) {
  if (tabs.length <= 1) return const SizedBox.shrink();
  if (tabs.length <= 5) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(children: [
        for (int i = 0; i < tabs.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(tabs[i].tabLabel),
              selected: selected == i,
              onSelected: (_) => onSelect(i),
              selectedColor: const Color(0xFF6C63FF),
              backgroundColor: const Color(0xFF1A1B2E),
              labelStyle: TextStyle(
                color: selected == i ? Colors.white : const Color(0xFF9A9AB0),
                fontSize: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
      ]),
    );
  }
  // Dropdown for >5 tabs
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: DropdownButton<int>(
      value: selected,
      isExpanded: true,
      dropdownColor: const Color(0xFF1A1B2E),
      style: const TextStyle(color: Color(0xFFEFEFF4)),
      items: [
        for (int i = 0; i < tabs.length; i++)
          DropdownMenuItem(value: i, child: Text(tabs[i].tabLabel))
      ],
      onChanged: (v) {
        if (v != null) onSelect(v);
      },
    ),
  );
}
