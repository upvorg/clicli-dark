import 'package:flutter/material.dart';

Widget ellipsisText(String text, {TextStyle style}) {
  return Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: style,
  );
}
