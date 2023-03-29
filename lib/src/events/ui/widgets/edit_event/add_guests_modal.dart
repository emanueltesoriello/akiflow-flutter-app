import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
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
                topLeft: Radius.circular(Dimension.radiusM),
                topRight: Radius.circular(Dimension.radiusM),
              ),
            ),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Padding(
              padding: const EdgeInsets.all(Dimension.padding),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const ScrollChip(),
                  const SizedBox(height: Dimension.padding),
                  Text(t.event.editEvent.addGuestModal.addGuest,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2(context),
                          )),
                  const SizedBox(height: Dimension.padding),
                  BorderedInputView(
                    focus: searchFocus,
                    hint: t.event.editEvent.addGuestModal.searchContact,
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
