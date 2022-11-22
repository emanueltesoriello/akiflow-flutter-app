import 'package:flutter/material.dart';
import 'package:mobile/src/availability/ui/widgets/slot_tile.dart';
import 'package:models/task/availability_config.dart';

class SlotList extends StatefulWidget {
  const SlotList({super.key, required this.configs, required this.isOpen});
  final List<AvailabilityConfig> configs;
  final bool isOpen;

  @override
  State<SlotList> createState() => _SlotListState();
}

class _SlotListState extends State<SlotList> {
  @override
  Widget build(BuildContext context) {
    if (widget.configs.isEmpty || widget.isOpen == false) {
      return const SizedBox();
    }
    return Expanded(
        child: ListView.builder(
            itemCount: widget.configs.length,
            itemBuilder: (BuildContext context, index) => SlotTile(config: widget.configs[index])));
  }
}
