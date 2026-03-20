import '/flutter_flow/flutter_flow_radio_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'survey_model.dart';
export 'survey_model.dart';

class SurveyWidget extends StatefulWidget {
  const SurveyWidget({super.key});

  @override
  State<SurveyWidget> createState() => _SurveyWidgetState();
}

class _SurveyWidgetState extends State<SurveyWidget> {
  late SurveyModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<int> answers = List<int>.filled(25, -1); // -1 indicates unanswered questions
  List<GlobalKey> keys = List.generate(25, (index) => GlobalKey());

  final List<String> questions = [
    "1. 청력 이상으로 전화를 원하는 것보다 덜 사용하십니까?",
    "2. 청력 이상으로 새로운 사람을 만날 때 난처하십니까?",
    "3. 청력 이상으로 여러 사람들과 함께 있는 것을 피하십니까?",
    "4. 청력 이상으로 짜증이 나십니까?",
    "5. 청력 이상으로 가족들과 대화할 때 좌절감을 느끼십니까?",
    "6. 모임에 참석했을 때 어려움을 느끼십니까?",
    "7. 청력 이상으로 스스로를 \"바보스럽다\" 또는 \"멍청하다\"고 느끼신 적이 있습니까?",
    "8. 누군가가 속삭일 때 알아듣기가 어렵습니까?",
    "9. 청력 이상으로 스스로 장애가 있다고 느끼십니까?",
    "10. 청력 이상으로 친구, 친척, 이웃들을 방문할 때 어려움을 느끼십니까?",
    "11. 청력 이상으로 종교 집회에 원하는 것보다 덜 참석하십니까?",
    "12. 청력 이상으로 성격이 과민해졌습니까?",
    "13. 청력 이상으로 친구, 친지, 이웃들을 원하는 만큼보다 덜 방문하게 되십니까?",
    "14. 청력 이상으로 가족들과 말다툼을 하시게 됩니까?",
    "15. 청력 이상으로 TV나 라디오를 들을 때 어려움을 느끼십니까?",
    "16. 청력 이상으로 쇼핑을 원하는 것보다 덜 하십니까?",
    "17. 청력 이상이나 이로 인한 어려움으로 실항한 적이 있습니까?",
    "18. 청력 이상으로 혼자 있고 싶다고 느끼십니까?",
    "19. 청력 이상으로 가족들과 대화를 덜 하게 됩니까?",
    "20. 청력 이상이 귀하의 개인 생활이나 사회생활을 제한하거나 방해한다고 느끼십니까?",
    "21. 청력 이상으로 친척이나 친구들과 식당에 있을 때 어려움을 느끼십니까?",
    "22. 청력 이상으로 우울하다고 느끼십니까?",
    "23. 청력 이상으로 TV나 라디오 청취를 원하는 것보다 덜 하게 되십니까?",
    "24. 청력 이상으로 친구들과 대화할 때 불편함을 느끼십니까?",
    "25. 청력 이상으로 여러 사람들과 함께 있을 때 소외된다고 느끼십니까?"
  ];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SurveyModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  void calculateScore() {
    if (answers.contains(-1)) {
      // If there are unanswered questions, scroll to the first one and highlight
      int firstUnanswered = answers.indexOf(-1);
      if (keys[firstUnanswered].currentContext != null) {
        Scrollable.ensureVisible(
          keys[firstUnanswered].currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 500),
        );
      }
      Flushbar(
        message: '모든 질문에 대답해주세요.',
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
      setState(() {}); // This will trigger a rebuild to show the red stars
    } else {
      // Calculate total score
      int totalScore = answers.reduce((value, element) => value + element);
      if (!mounted) return; // Check if the widget is still mounted
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ResultCard(totalScore: totalScore);
        },
      );
    }
  }

  Widget buildQuestion(int index, String question) {
    return Padding(
      key: keys[index],
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (answers[index] == -1)
                const Icon(Icons.star, color: Colors.red, size: 16),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Radio(
                value: 4,
                groupValue: answers[index],
                onChanged: (int? value) {
                  setState(() {
                    answers[index] = value!;
                  });
                },
              ),
              const Text('예', style: TextStyle(fontSize: 20)),
              Radio(
                value: 2,
                groupValue: answers[index],
                onChanged: (int? value) {
                  setState(() {
                    answers[index] = value!;
                  });
                },
              ),
              const Text('가끔', style: TextStyle(fontSize: 20)),
              Radio(
                value: 0,
                groupValue: answers[index],
                onChanged: (int? value) {
                  setState(() {
                    answers[index] = value!;
                  });
                },
              ),
              const Text('아니오', style: TextStyle(fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int answeredCount = answers.where((answer) => answer != -1).length;
    double progressPercent = (answeredCount / answers.length) * 100;

    return GestureDetector(
    onTap: () => _model.unfocusNode.canRequestFocus
        ? FocusScope.of(context).requestFocus(_model.unfocusNode)
        : FocusScope.of(context).unfocus(),
    child: Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: const [],
        title: Row(
          children: [
            Flexible(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'assets/images/neuroHearLogoBG.png',
                  height: 50.0, // Adjust the height as needed
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '검사 진행도: $answeredCount/25 (${progressPercent.toStringAsFixed(0)}% 완료)',
                  style: FlutterFlowTheme.of(context).headlineMedium.override(
                        fontFamily: 'Outfit',
                        color: Colors.black,
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                      ),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 2.0,
        toolbarHeight: 60.0, // Adjust the height as needed
      ),

        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: List.generate(questions.length, (index) {
                        return buildQuestion(
                          index,
                          questions[index],
                        );
                      }),
                    ),
                  ),
                ),
              ),
              FFButtonWidget(
                onPressed: calculateScore,
                text: '결과 보기',
                options: FFButtonOptions(
                  width: 150,
                  height: 50,
                  color: FlutterFlowTheme.of(context).primary,
                  textStyle: FlutterFlowTheme.of(context)
                      .subtitle2
                      .override(fontFamily: 'Outfit', color: Colors.white, fontSize: 20),
                  elevation: 2,
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResultCard extends StatelessWidget {
  final int totalScore;

  const ResultCard({super.key, required this.totalScore});

  @override
  Widget build(BuildContext context) {
    String resultMessage;
    Color resultColor;

    if (totalScore <= 6) {
      resultMessage =
          "0~6점 : 현재 청력으로 인한 불편함이 현저히 낮으며, 청력 손실이 의심되지 않음.";
      resultColor = Colors.green;
    } else if (totalScore <= 42) {
      resultMessage =
          "7~42점 : 현재 청력으로 인한 불편함을 겪고 있으며, 청력 손실이 다소 의심됨. 임상의 방문을 권유함.";
      resultColor = Colors.yellow;
    } else {
      resultMessage =
          "43점 이상 : 현재 청력으로 인해 일상생활이 어려우며, 청력 손실이 의심됨. 임상의 방문을 권유함.";
      resultColor = Colors.red;
    }

    return AlertDialog(
      title: const Text(
        '결과',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 30),
        ),
      content: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              '100점 만점에 $totalScore 입니다.',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              color: resultColor,
              height: 25,
              width: double.infinity,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      const Text('0~6점', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        color: Colors.yellow,
                      ),
                      const SizedBox(width: 10),
                      const Text('7~42점', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        height: 20,
                        width: 20,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 10),
                      const Text('43점 이상', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              resultMessage,
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('확인', style: TextStyle(fontSize: 20)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}