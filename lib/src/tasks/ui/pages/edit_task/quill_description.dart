import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_launcher/url_launcher.dart';
import 'package:i18n/strings.g.dart';

class QuillDescription extends StatefulWidget {
  final QuillEditorController quillEditorController;
  final ValueNotifier<quill.QuillController> quillController;
  final String initialText;
  final Function(String) onChange;
  final Function()? onTap;
  final FocusNode descriptionFocusNode;
  final Function(Map<dynamic, dynamic> delta) setInitialDelta;

  const QuillDescription(
      {super.key,
      required this.quillEditorController,
      required this.quillController,
      required this.initialText,
      this.onTap,
      required this.descriptionFocusNode,
      required this.onChange,
      required this.setInitialDelta});

  @override
  State<QuillDescription> createState() => _QuillDescriptionState();
}

class _QuillDescriptionState extends State<QuillDescription> {
  @override
  void initState() {
    widget.quillEditorController.onEditorLoaded(() async {
      debugPrint('Editor Loaded :)');
      await widget.quillEditorController.insertText(widget.initialText, index: 0);
      var delta = await widget.quillEditorController.getDelta();
      quill.Document document = quill.Document.fromJson(delta["ops"]);

      widget.setInitialDelta(delta);
      widget.quillController.value =
          quill.QuillController(document: document, selection: const TextSelection.collapsed(offset: 0));
      widget.quillController.value.changes.listen((change) async {
        widget.quillEditorController.setDelta({"ops": widget.quillController.value.document.toDelta().toJson()});
        var htmlText = await widget.quillEditorController.getText();
        widget.onChange(htmlText);
      });
      widget.quillController.value.moveCursorToEnd();
    });
    super.initState();
  }

  // Workaround to have both htmlEditor and flutterQUill library enabled.
  // We use the quillHtmlEditor conversions from Html to delta and pass everything to flutter quill library
  // this cause quill library seems better at the moment, but don't have a way to convert Htlm in delta and reverse
  _quillHtmlEditor() {
    return Opacity(
      opacity: 0,
      child: SizedBox(
        width: 0,
        height: 0,
        child: QuillHtmlEditor(
          backgroundColor: Colors.white,
          // hintTextStyle: TextStyle(fontSize: 18, color: Colors.black12, fontWeight: FontWeight.normal),
          // text: "<h1>Hello</h1>This is a quill html editor example 😊",
          // hintText: 'Hint text goes here',
          hintText: null,
          controller: widget.quillEditorController,
          isEnabled: true,
          ensureVisible: false,
          minHeight: 0,
          textStyle:
              const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal, fontFamily: 'Roboto'),
          //  hintTextStyle: _hintTextStyle,
          hintTextAlign: TextAlign.start,
          padding: const EdgeInsets.only(left: 10, top: 10),
          hintTextPadding: const EdgeInsets.only(left: 20),
          // backgroundColor: _backgroundColor,
          loadingBuilder: (context) {
            return const Center(
                child: CircularProgressIndicator(
              strokeWidth: 0.4,
            ));
          },
          onFocusChanged: (focus) {
            debugPrint('has focus $focus');
          },

          onEditorCreated: () {
            debugPrint('Editor has been loaded');
          },
        ),
      ),
    );
  }

  Widget _description() {
    return Stack(
      children: [
        _quillHtmlEditor(),
        ValueListenableBuilder<quill.QuillController>(
          valueListenable: widget.quillController,
          builder: (context, value, child) => Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: ColorsExt.akiflow500(context)!.withOpacity(0.1),
              ),
            ),
            child: GestureDetector(
              onTap: widget.onTap,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Column(
                  children: [
                    quill.QuillEditor(
                      key: UniqueKey(),
                      controller: value,
                      readOnly: false,
                      enableSelectionToolbar: true,
                      scrollController: ScrollController(),
                      scrollable: true,
                      focusNode: widget.descriptionFocusNode,
                      autoFocus: false,
                      expands: false,
                      padding: EdgeInsets.zero,
                      keyboardAppearance: Brightness.light,
                      placeholder: t.task.description,
                      linkActionPickerDelegate: (BuildContext context, String link, node) async {
                        launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication);
                        return quill.LinkMenuAction.none;
                      },
                      customStyles: quill.DefaultStyles(
                        placeHolder: quill.DefaultTextBlockStyle(
                          const TextStyle(
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                          const quill.VerticalSpacing(0, 0),
                          const quill.VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _description();
  }
}
