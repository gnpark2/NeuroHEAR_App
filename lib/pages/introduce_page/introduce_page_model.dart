import '/flutter_flow/flutter_flow_util.dart';
import 'introduce_page_widget.dart' show IntroducePageWidget;
import 'package:flutter/material.dart';

class IntroducePageModel extends FlutterFlowModel<IntroducePageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
  }
}
