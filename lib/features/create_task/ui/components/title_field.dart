// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:i18n/strings.g.dart';

// import '../../../../style/colors.dart';
// import '../../../../utils/interactive_webview.dart';
// import '../../../edit_task/cubit/edit_task_cubit.dart';
// import '../../../main/ui/chrono_model.dart';

// class TitleField extends StatelessWidget {
//   const TitleField(
//       {Key? key,
//       required this.simpleTitleController,
//       required this.isTitleEditing,
//       required this.titleFocus,
//       required this.titleController})
//       : super(key: key);
//   final TextEditingController simpleTitleController;
//   final TextEditingController titleController;
//   final ValueListenable<bool> isTitleEditing;
//   final FocusNode titleFocus;
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//         valueListenable: isTitleEditing,
//         builder: (context, bool isTitleEditing, child) {
//           return TextField(
//             controller: isTitleEditing ? simpleTitleController : titleController,
//             focusNode: titleFocus,
//             textCapitalization: TextCapitalization.sentences,
//             maxLines: null,
//             keyboardType: TextInputType.multiline,
//             decoration: InputDecoration(
//               contentPadding: EdgeInsets.zero,
//               isDense: true,
//               hintText: t.addTask.titleHint,
//               border: InputBorder.none,
//               hintStyle: TextStyle(
//                 color: ColorsExt.grey3(context),
//                 fontSize: 20,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             style: TextStyle(
//               color: ColorsExt.grey2(context),
//               fontSize: 20,
//               fontWeight: FontWeight.w500,
//             ),
//             onTap: () {
//               if (!isTitleEditing) {
//                 simpleTitleController.text = titleController.text;
//                 simpleTitleController.selection = titleController.selection;

//                 isTitleEditing = true;
//               }
//             },
//             onChanged: (value) async {
//               if (isTitleEditing) {
//                 titleController.text = value;
//                 titleController.selection = simpleTitleController.selection;

//                 int currentSelection = simpleTitleController.selection.baseOffset;
//                 String lastCharInserted = value.substring(currentSelection - 1, currentSelection);

//                 if (lastCharInserted == " ") {
//                   checkTitleChrono(value);
//                 }
//               } else {
//                 simpleTitleController.text = value;
//                 simpleTitleController.selection = titleController.selection;
//               }

//               context.read<EditTaskCubit>().updateTitle(value);

//               List<ChronoModel>? chronoParsed = await InteractiveWebView.chronoParse(value);

//               _checkContainsNonParsableText();

//               _checkTitleWithChrono(chronoParsed, value, isFromAction: false);
//             },
//           );
//         });
//   }
// }
