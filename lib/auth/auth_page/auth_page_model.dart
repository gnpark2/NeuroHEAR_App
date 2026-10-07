import '/flutter_flow/flutter_flow_util.dart';
import 'auth_page_widget.dart' show AuthPageWidget;
import 'package:flutter/material.dart';
class AuthPageModel extends FlutterFlowModel<AuthPageWidget> {
  ///  State fields for stateful widgets in this page.

  final unfocusNode = FocusNode();
  // State field(s) for phoneNumber_Create widget.
  FocusNode? phoneNumberCreateFocusNode;
  TextEditingController? phoneNumberCreateTextController;
  String? Function(BuildContext, String?)?
      phoneNumberCreateTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    unfocusNode.dispose();
    phoneNumberCreateFocusNode?.dispose();
    phoneNumberCreateTextController?.dispose();
  }
}
