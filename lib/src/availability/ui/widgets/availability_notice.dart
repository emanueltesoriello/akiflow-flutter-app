import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/task/notice.dart';

import '../cubit/availability_cubit.dart';

class AvailabilityNotice extends StatefulWidget {
  const AvailabilityNotice({super.key});

  @override
  State<AvailabilityNotice> createState() => _AvailabilityNoticeState();
}

class _AvailabilityNoticeState extends State<AvailabilityNotice> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: context.read<AvailabilityCubit>().getNoticeStatus(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data == false) {
            return GestureDetector(
              onLongPress: () {},
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Notice(
                  title: "Coming Soon",
                  subtitle: "The full calendar experience is coming in the near future",
                  icon: Icons.info_outline,
                  onClose: () {
                    context.read<AvailabilityCubit>().noticeClosed();
                    setState(() {});
                  },
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        });
  }
}
