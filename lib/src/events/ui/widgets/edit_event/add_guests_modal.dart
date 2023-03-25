import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/bordered_input_view.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/edit_event/contact_row.dart';
import 'package:models/contact/contact.dart';

class AddGuestsModal extends StatefulWidget {
  final Function(Contact contact) updateAtendeesUi;
  const AddGuestsModal({super.key, required this.updateAtendeesUi});

  @override
  State<AddGuestsModal> createState() => _AddGuestsModalState();
}

class _AddGuestsModalState extends State<AddGuestsModal> {
  final FocusNode searchFocus = FocusNode();
  Timer? debounce;

  @override
  void initState() {
    searchFocus.requestFocus();
    debounce?.cancel();
    super.initState();
  }

  @override
  void dispose() {
    searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Contact> searchedContacts = context.watch<EventsCubit>().state.searchedContacts;

    return BlocBuilder<EventsCubit, EventsCubitState>(
      builder: (context, state) {
        return Material(
          color: Theme.of(context).backgroundColor,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ScrollChip(),
                  const SizedBox(height: 12),
                  Text(
                    'Add guest',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: ColorsExt.grey2(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  BorderedInputView(
                    focus: searchFocus,
                    hint: "Search contact",
                    onChanged: (value) {
                      if (debounce?.isActive ?? false) debounce?.cancel();
                      debounce = Timer(const Duration(milliseconds: 500), () {
                        context.read<EventsCubit>().fetchSearchedContacts(value);
                      });
                    },
                  ),
                  SizedBox(
                    height: 190,
                    child: ListView.builder(
                      itemCount: searchedContacts.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            widget.updateAtendeesUi(searchedContacts.elementAt(index));
                            Navigator.of(context).pop();
                          },
                          child: ContactRow(
                            contact: searchedContacts.elementAt(index),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
