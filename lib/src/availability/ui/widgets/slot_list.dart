import 'package:flutter/material.dart';
import 'package:mobile/src/availability/ui/widgets/slot_tile.dart';
import 'package:models/task/availability_config.dart';

class SlotList extends StatelessWidget {
  const SlotList({super.key, required this.configs, required this.isOpen});
  final List<AvailabilityConfig> configs;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    if (configs.isEmpty || isOpen==false) {
      return const SizedBox();
    }
    return Expanded(
        child: ListView.builder(
            itemCount: configs.length, itemBuilder: (BuildContext context, index) => SlotTile(config: configs[index])));
  }
}
