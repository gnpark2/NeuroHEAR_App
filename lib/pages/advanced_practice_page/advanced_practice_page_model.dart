import '/flutter_flow/flutter_flow_util.dart';
import 'advanced_practice_page_widget.dart' show AdvancedPracticePageWidget;
import 'package:flutter/material.dart';

class AdvancedPracticePageModel
    extends FlutterFlowModel<AdvancedPracticePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
