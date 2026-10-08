import 'package:neuro_h_e_a_r/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '/backend/backend.dart';
import 'calendar_page_model.dart';
export 'calendar_page_model.dart';

class CalendarPageWidget extends StatefulWidget {
  const CalendarPageWidget({super.key});

  @override
  State<CalendarPageWidget> createState() => _CalendarPageWidgetState();
}

class _CalendarPageWidgetState extends State<CalendarPageWidget> {
  late CalendarPageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  late Map<DateTime, List<Map<String, dynamic>>> _events;
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  final CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();

    _model = createModel(context, () => CalendarPageModel());
    _focusedDay = DateTime.now();
    _selectedDay = _focusedDay;
    _events = {};
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  DateTime convertToKST(DateTime utcTime) {
    return utcTime.toUtc().add(const Duration(hours: 9));
  }

  DateTime normalizeDate(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime.now().subtract(
      const Duration(days: 365 * 10),
    );
    final lastDay = DateTime.now().add(
      const Duration(days: 365 * 10),
    );

    if (currentUserReference == null) {
      return const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('로그인 후 기록을 확인해주세요.'),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: StreamBuilder<List<BasicResultsRecord>>(
                    // 과거 CreatedTime 필드로 저장된 문서도 조회합니다.
                    stream: queryBasicResultsRecord(
                      parent: currentUserReference,
                    ),
                    builder: (context, basicSnapshot) {
                      return StreamBuilder<List<AdvancedResultsRecord>>(
                        stream: queryAdvancedResultsRecord(
                          parent: currentUserReference,
                        ),
                        builder: (context, advancedSnapshot) {
                          if (basicSnapshot.hasError ||
                              advancedSnapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  const Text('훈련 기록을 불러오지 못했습니다.'),
                                  TextButton(
                                    onPressed: () => setState(() {}),
                                    child: const Text('다시 시도'),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (!basicSnapshot.hasData ||
                              !advancedSnapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          _events.clear();

                          // 모델의 getter가 현재·과거 필드명을 처리합니다.
                          // 조회 후 날짜 기준으로 최신순 정렬합니다.
                          final basicRecords = List<BasicResultsRecord>.of(
                            basicSnapshot.data!,
                          )..sort(
                              (a, b) =>
                                  (b.createdTime ?? DateTime(1970)).compareTo(
                                a.createdTime ?? DateTime(1970),
                              ),
                            );

                          final advancedRecords =
                              List<AdvancedResultsRecord>.of(
                            advancedSnapshot.data!,
                          )..sort(
                                  (a, b) => (b.createdTime ?? DateTime(1970))
                                      .compareTo(
                                    a.createdTime ?? DateTime(1970),
                                  ),
                                );

                          // 기본 훈련 기록
                          for (final record in basicRecords) {
                            final createdTime = record.createdTime;

                            if (createdTime == null) {
                              continue;
                            }

                            final numOfQuestions = record.numOfQuestions;

                            if (numOfQuestions <= 0) {
                              continue;
                            }

                            final date = normalizeDate(
                              convertToKST(createdTime),
                            );

                            _events.putIfAbsent(date, () => []);

                            _events[date]!.add({
                              'type': '기본',
                              'numOfQuestions': numOfQuestions,
                              'numOfCollectQuestions':
                                  record.numOfCollectQuestions,
                            });
                          }

                          // 심화 훈련 기록
                          for (final record in advancedRecords) {
                            final createdTime = record.createdTime;

                            if (createdTime == null) {
                              continue;
                            }

                            final numOfQuestions = record.numOfQuestions;

                            if (numOfQuestions <= 0) {
                              continue;
                            }

                            final date = normalizeDate(
                              convertToKST(createdTime),
                            );

                            _events.putIfAbsent(date, () => []);

                            _events[date]!.add({
                              'type': '소음',
                              'numOfQuestions': numOfQuestions,
                              'numOfCollectQuestions':
                                  record.numOfCollectQuestions,
                            });
                          }

                          final selectedEvents =
                              _events[normalizeDate(_selectedDay)] ?? [];

                          return Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 20),
                                child: TableCalendar(
                                  availableGestures:
                                      AvailableGestures.horizontalSwipe,
                                  locale: 'ko_KR',
                                  rowHeight: 80,
                                  daysOfWeekHeight: 40.0,
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                  ),
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        231,
                                        180,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  firstDay: firstDay,
                                  lastDay: lastDay,
                                  focusedDay: _focusedDay,
                                  selectedDayPredicate: (day) {
                                    return isSameDay(_selectedDay, day);
                                  },
                                  calendarFormat: _calendarFormat,
                                  onFormatChanged: null,
                                  onDaySelected: (selectedDay, focusedDay) {
                                    setState(() {
                                      _selectedDay = selectedDay;
                                      _focusedDay = focusedDay;
                                    });
                                  },
                                  eventLoader: (day) {
                                    final dateKey = normalizeDate(day);
                                    return _events[dateKey] ?? [];
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    dowBuilder: (context, day) {
                                      final text =
                                          DateFormat.E('ko_KR').format(day);

                                      if (day.weekday == DateTime.sunday) {
                                        return const Center(
                                          child: Text(
                                            '일',
                                            style: TextStyle(
                                              color: Colors.red,
                                            ),
                                          ),
                                        );
                                      }

                                      return Container(
                                        width: 50,
                                        alignment: Alignment.center,
                                        child: Text(
                                          text,
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    },
                                    headerTitleBuilder: (context, day) {
                                      return Column(
                                        children: [
                                          Text(
                                            DateFormat.yMMMM('ko_KR')
                                                .format(day),
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    markerBuilder: (context, date, events) {
                                      int trainingCount(String type) {
                                        return events.fold<int>(
                                          0,
                                          (total, event) {
                                            if (event
                                                    is! Map<String, dynamic> ||
                                                event['type'] != type) {
                                              return total;
                                            }

                                            final count =
                                                event['numOfQuestions'];

                                            return total +
                                                (count is num
                                                    ? count.toInt()
                                                    : 0);
                                          },
                                        );
                                      }

                                      final basicCount = trainingCount('기본');
                                      final advancedCount = trainingCount('소음');

                                      if (basicCount == 0 &&
                                          advancedCount == 0) {
                                        return null;
                                      }

                                      Widget countBadge(
                                        int count,
                                        Color color,
                                      ) {
                                        return Container(
                                          width: double.infinity,
                                          height: 18,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '$count회',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 2,
                                        child: Center(
                                          child: Container(
                                            width: 40.0,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (basicCount > 0)
                                                  countBadge(
                                                    basicCount,
                                                    Colors.blue,
                                                  ),
                                                if (basicCount > 0 &&
                                                    advancedCount > 0)
                                                  const SizedBox(
                                                    height: 2,
                                                  ),
                                                if (advancedCount > 0)
                                                  countBadge(
                                                    advancedCount,
                                                    Colors.red,
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    defaultBuilder:
                                        (context, date, focusedDay) {
                                      return Container(
                                        margin: const EdgeInsets.all(8.0),
                                        alignment: Alignment.topCenter,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${date.day}',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    todayBuilder: (context, date, focusedDay) {
                                      return Center(
                                        child: Container(
                                          width: 40.0,
                                          height: 40.0,
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(
                                              10.0,
                                            ),
                                          ),
                                          margin: const EdgeInsets.only(
                                            bottom: 40.0,
                                            top: 8.0,
                                            left: 8.0,
                                            right: 8.0,
                                          ),
                                          alignment: Alignment.center,
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Text(
                                              '${date.day}',
                                              style: const TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    selectedBuilder:
                                        (context, date, focusedDay) {
                                      final now = DateTime.now();

                                      final isToday = date.year == now.year &&
                                          date.month == now.month &&
                                          date.day == now.day;

                                      if (isToday) {
                                        return Center(
                                          child: Stack(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    width: 2,
                                                    color: Colors.purple,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    10,
                                                  ),
                                                ),
                                                margin: const EdgeInsets.only(
                                                  top: 8.0,
                                                ),
                                                alignment: Alignment.topCenter,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    '${date.day}',
                                                    style: const TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                  margin: const EdgeInsets.only(
                                                    bottom: 40.0,
                                                    top: 11.0,
                                                    left: 8.0,
                                                    right: 8.0,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: FittedBox(
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      '${date.day}',
                                                      style: const TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            width: 2,
                                            color: Colors.purple,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        margin: const EdgeInsets.only(
                                          top: 8.0,
                                        ),
                                        alignment: Alignment.topCenter,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${date.day}',
                                            style: const TextStyle(
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    outsideBuilder:
                                        (context, date, focusedDay) {
                                      return Container(
                                        margin: const EdgeInsets.all(8.0),
                                        alignment: Alignment.topCenter,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${date.day}',
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    holidayBuilder:
                                        (context, date, focusedDay) {
                                      return Container(
                                        margin: const EdgeInsets.all(8.0),
                                        alignment: Alignment.topCenter,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '${date.day}',
                                            style: const TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: selectedEvents.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: selectedEvents.length,
                                        itemBuilder: (context, index) {
                                          final event = selectedEvents[index];

                                          final type = event['type'];
                                          final numOfQuestions =
                                              event['numOfQuestions'];
                                          final numOfCollectQuestions =
                                              event['numOfCollectQuestions'];

                                          final ratio = numOfQuestions == 0
                                              ? '해당 훈련을 진행하지 않았습니다.'
                                              : '정답률: ${(numOfCollectQuestions / numOfQuestions * 100).toStringAsFixed(2)}';

                                          return Container(
                                            margin: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 8,
                                            ),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: type == '기본'
                                                  ? Colors.blue[100]
                                                  : Colors.red[100],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: type == '기본'
                                                    ? Colors.blue
                                                    : Colors.red,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Type: $type' '훈련 결과',
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  '정답 수: $numOfCollectQuestions개',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  '문제 수: $numOfQuestions개',
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                                Text(
                                                  ratio,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : const Center(
                                        child: Text(
                                          '해당 날짜에는 훈련을 하지 않았습니다.',
                                        ),
                                      ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
