import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/stylable_text_editing_controller.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/src/base/ui/widgets/task/components/title_nlp_text_field.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/create_task_actions.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/description_field.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/duration_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/label_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/priority_widget.dart';
import 'package:mobile/src/tasks/ui/widgets/create_tasks/send_task_button.dart';
import 'package:models/nlp/nlp_date_time.dart';
import 'package:models/task/task.dart';

class CreateTaskModal extends StatefulWidget {
  const CreateTaskModal({Key? key, this.sharedText}) : super(key: key);
  final String? sharedText;
  @override
  State<CreateTaskModal> createState() => _CreateTaskModalState();
}

class _CreateTaskModalState extends State<CreateTaskModal> {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController controller = TextEditingController();

  final FocusNode titleFocus = FocusNode();

  final ValueNotifier<bool> isTitleEditing = ValueNotifier<bool>(false);
  final ScrollController parentScrollController = ScrollController();
  bool showRefresh = false;
  Color? backgroundPlanColor;
  Color? borderPlanColor;
  Task? previousUpdatedTask;

  late final StylableTextEditingController simpleTitleController;

  @override
  void initState() {
    titleFocus.requestFocus();

    EditTaskCubit editTaskCubit = context.read<EditTaskCubit>();
    editTaskCubit.onOpen();
    simpleTitleController = editTaskCubit.simpleTitleController;
    String descriptionHtml = widget.sharedText ?? editTaskCubit.state.originalTask.description ?? '';
    descriptionController.text = descriptionHtml;
    context.read<EditTaskCubit>().updateDescription(descriptionHtml);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    simpleTitleController.done();
  }

  _onCreateClick() async {
    try {
      setState(() {
        showRefresh = true;
      });
      HapticFeedback.mediumImpact();

      var cubit = context.read<EditTaskCubit>();

      await cubit.create();
      print('created complete');

      setState(() {
        showRefresh = false;
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        showRefresh = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.toString()),
      ));
      locator<SentryService>().captureException(Exception(e.toString()));
    }
  }

  animatePlanDate() {
    try {
      if (previousUpdatedTask?.date != context.read<EditTaskCubit>().state.updatedTask.date ||
          previousUpdatedTask?.datetime! != context.read<EditTaskCubit>().state.updatedTask.datetime) {
        setState(() {
          backgroundPlanColor = Colors.white;
          borderPlanColor = ColorsExt.jordyBlue400(context);
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            backgroundPlanColor = null;
            borderPlanColor = null;
          });
        });
        previousUpdatedTask = context.read<EditTaskCubit>().state.updatedTask;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: ListView(
          controller: parentScrollController,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimension.radiusM),
                  topRight: Radius.circular(Dimension.radiusM),
                ),
              ),
              margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Column(
                  children: [
                    const DurationWidget(),
                    const PriorityWidget(),
                    //const LabelWidget(),
                    const SizedBox(height: Dimension.padding),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleNlpTextField(
                            stylableController: simpleTitleController,
                            titleFocus: titleFocus,
                            onChanged: (String value, {String? textWithoutDate}) async {
                              context.read<EditTaskCubit>().updateTitle(value,
                                  mapping: simpleTitleController.mapping, textWithoutDate: textWithoutDate);
                            },
                            setToInbox: () {
                              context.read<EditTaskCubit>().setToInbox();
                            },
                            onDateDetected: (NLPDateTime nlpDateTime) {
                              context.read<EditTaskCubit>().onDateDetected(context, nlpDateTime);
                              animatePlanDate();
                            },
                          ),
                          const SizedBox(height: Dimension.paddingS),
                          DescriptionField(descriptionController: descriptionController),
                          const SizedBox(height: Dimension.paddingS),
                          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            CreateTaskActions(
                                titleController: simpleTitleController,
                                titleFocus: titleFocus,
                                backgroundPlanColor: backgroundPlanColor,
                                borderPlanColor: borderPlanColor),
                            GestureDetector(
                              onVerticalDragUpdate: (_) {},
                              child: showRefresh
                                  ? const Center(
                                      child: Padding(
                                      padding: EdgeInsets.all(2.0),
                                      child: CircularProgressIndicator(),
                                    ))
                                  : SendTaskButton(onTap: () {
                                      _onCreateClick();
                                    }),
                            ),
                          ]),
                          const SizedBox(height: Dimension.padding),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ]),
    );
  }
}
