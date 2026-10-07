import '/flutter_flow/flutter_flow_util.dart';
import 'self_test_page_widget.dart' show SelfTestPageWidget;
import 'package:flutter/material.dart';

class SelfTestPageModel extends FlutterFlowModel<SelfTestPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
