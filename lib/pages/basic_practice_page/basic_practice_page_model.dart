import '/flutter_flow/flutter_flow_util.dart';
import 'basic_practice_page_widget.dart' show BasicPracticePageWidget;
import 'package:flutter/material.dart';

class BasicPracticePageModel extends FlutterFlowModel<BasicPracticePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
