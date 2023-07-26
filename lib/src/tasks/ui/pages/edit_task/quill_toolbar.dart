import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:mobile/common/style/sizes.dart';

class QuillToolbar extends StatelessWidget {
  final quill.QuillController controller;

  QuillToolbar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    const quillToolBarIconSize = 20.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      child: Material(
        child: Container(
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + Dimension.paddingXS, top: Dimension.paddingXS),
          child: quill.QuillToolbar(
            toolbarSectionSpacing: 0,
            children: [
              quill.ToggleStyleButton(
                attribute: quill.Attribute.bold,
                icon: Icons.format_bold,
                iconSize: quillToolBarIconSize,
                controller: controller,
              ),
              quill.ToggleStyleButton(
                attribute: quill.Attribute.italic,
                icon: Icons.format_italic,
                iconSize: quillToolBarIconSize,
                controller: controller,
              ),
              quill.ToggleStyleButton(
                attribute: quill.Attribute.underline,
                icon: Icons.format_underline,
                iconSize: quillToolBarIconSize,
                controller: controller,
              ),
              quill.ClearFormatButton(
                icon: Icons.format_clear,
                iconSize: quillToolBarIconSize,
                controller: controller,
              ),
              const SizedBox(width: Dimension.padding),
              quill.SelectHeaderStyleButton(
                controller: controller,
                iconSize: quillToolBarIconSize,
                attributes: const [
                  quill.Attribute.h1,
                  quill.Attribute.h2,
                ],
              ),
              quill.ToggleStyleButton(
                attribute: quill.Attribute.ul,
                controller: controller,
                icon: Icons.format_list_bulleted,
                iconSize: quillToolBarIconSize,
              ),
              quill.ToggleStyleButton(
                attribute: quill.Attribute.ol,
                controller: controller,
                icon: Icons.format_list_numbered,
                iconSize: quillToolBarIconSize,
              ),
              const SizedBox(width: Dimension.paddingXS),
            ],
          ),
        ),
      ),
    );
  }
}
