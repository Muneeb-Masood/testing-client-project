import 'package:test/utilities/constants.dart';
import 'package:flutter/material.dart';

class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {super.key, this.maxHeight});

  final String text;
  final double? maxHeight;

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText>
    with TickerProviderStateMixin<ExpandableText> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxHeight = widget.maxHeight ?? size.height * 0.1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: ConstrainedBox(
            constraints: isExpanded
                ? const BoxConstraints()
                : BoxConstraints(maxHeight: maxHeight),
            child: Text(
              widget.text,
              softWrap: true,
              style: kTextStyle.copyWith(fontSize: 12),
              overflow: TextOverflow.fade,
            ),
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(size.width * 0.14, size.height * 0.02),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
              isExpanded
                  ? getTranslatedText("کم دیکھیں..", 'See less..')
                  : getTranslatedText("مزید دیکھیں..", "See more.."),
              style: reminderButtonStyle
              //   (
              //   decoration: TextDecoration.underline,
              //   color: Colors.grey.shade700,
              //   fontFamily: 'Georgia',
              //   fontSize: 13,
              //   fontWeight: FontWeight.w100,
              // ),
              ),
          onPressed: () => setState(
            () {
              isExpanded = !isExpanded;
            },
          ),
        )
      ],
    );
  }
}
