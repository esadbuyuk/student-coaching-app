import 'package:flutter/material.dart';

import '../../model/my_constants.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialText;
  final bool isUserAuthenticated;
  final ValueChanged<String> onTextChanged;

  const EditableTextWidget({
    Key? key,
    required this.initialText,
    required this.onTextChanged,
    required this.isUserAuthenticated,
  }) : super(key: key);

  @override
  EditableTextWidgetState createState() => EditableTextWidgetState();
}

class EditableTextWidgetState extends State<EditableTextWidget> {
  bool _isEditing = false;
  late TextEditingController _controller;
  TextStyle styleOfEditableTexts = myTonicStyle(mySecondaryTextColor);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isEditing = widget.isUserAuthenticated;
        });
      },
      child: _isEditing
          ? TextField(
              controller: _controller,
              autofocus: true,
              cursorColor: myIconsColor,
              decoration: const InputDecoration(
                filled: true,
                fillColor: myPrimaryColor,
                hintText: '...',
                hintStyle: TextStyle(
                  color: myIconsColor,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: myAccentColor,
                    width: 2,
                  ),
                ),
              ),
              onSubmitted: (newValue) {
                setState(() {
                  _isEditing = false;
                });
              },
              onEditingComplete: () {
                setState(() {
                  _isEditing = false;
                  widget.onTextChanged(_controller.text);
                });
              },
            )
          : Text(
              widget.initialText.toUpperCase(),
              style: styleOfEditableTexts,
            ),
    );
  }
}
