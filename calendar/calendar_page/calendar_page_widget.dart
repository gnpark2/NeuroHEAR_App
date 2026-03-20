import 'package:neuro_h_e_a_r/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  CalendarFormat _calendarFormat = CalendarFormat.month;

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
    return utcTime.add(Duration(hours: 9));
  }

  // Function to normalize DateTime to date only (year, month, day)
  DateTime normalizeDate(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime.now().subtract(Duration(days: 365 * 10));
    final lastDay = DateTime.now().add(Duration(days: 365 * 10));

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
                  padding: EdgeInsets.only(bottom: 20),
                  child: StreamBuilder<List<BasicResultsRecord>>(
                    stream: queryBasicResultsRecord(
                      parent: currentUserReference,
                      queryBuilder: (query) => query.orderBy('createdTime', descending: true),
                    ),
                    builder: (context, basicSnapshot) {
                      return StreamBuilder<List<AdvancedResultsRecord>>(
                        stream: queryAdvancedResultsRecord(
                          parent: currentUserReference,
                          queryBuilder: (query) => query.orderBy('createdTime', descending: true),
                        ),
                        builder: (context, advancedSnapshot) {
                          if (!basicSnapshot.hasData || !advancedSnapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          // Clear previous events
                          _events.clear();

                          // Process BasicResults
                          for (var record in basicSnapshot.data!) {
                            final createdTime = record.snapshotData["createdTime"];
                            if (createdTime != null) {
                              final kstTime = convertToKST(createdTime);
                              final date = normalizeDate(kstTime);
                              final numOfQuestions = record.snapshotData["numOfQuestions"];
                              final numOfCollectQuestions = record.snapshotData["numOfCollectQuestions"];

                              if (_events[date] == null) {
                                _events[date] = [];
                              }

                              _events[date]!.add({
                                'type': '기본',
                                'numOfQuestions': numOfQuestions,
                                'numOfCollectQuestions': numOfCollectQuestions,
                              });
                            }
                          }

                          // Process AdvancedResults
                          for (var record in advancedSnapshot.data!) {
                            final createdTime = record.snapshotData["createdTime"];
                            if (createdTime != null) {
                              final kstTime = convertToKST(createdTime);
                              final date = normalizeDate(kstTime);
                              final numOfQuestions = record.snapshotData["numOfQuestions"];
                              final numOfCollectQuestions = record.snapshotData["numOfCollectQuestions"];

                              if (_events[date] == null) {
                                _events[date] = [];
                              }

                              _events[date]!.add({
                                'type': '소음',
                                'numOfQuestions': numOfQuestions,
                                'numOfCollectQuestions': numOfCollectQuestions,
                              });
                            }
                          }

                          // Get selected day's events
                          final selectedEvents = _events[normalizeDate(_selectedDay)] ?? [];

                          return Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(bottom: 20),
                                child: TableCalendar(
                                  availableGestures: AvailableGestures.horizontalSwipe,
                                  locale: 'ko_KR',
                                  rowHeight: 80,
                                  daysOfWeekHeight: 40.0,
                                  headerStyle: HeaderStyle(
                                    formatButtonVisible: false,
                                  ),
                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 231, 180),
                                      borderRadius: BorderRadius.circular(20),
                                    )),
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
                                      _focusedDay = focusedDay; // update `_focusedDay` here as well
                                    });
                                  },
                                  eventLoader: (day) {
                                    final dateKey = normalizeDate(day);
                                    final eventsForDay = _events[dateKey] ?? [];
                                    return eventsForDay;
                                  },
                                  calendarBuilders: CalendarBuilders(
                                    dowBuilder: (context, day) {
                                      final text = DateFormat.E('ko_KR').format(day);
                                      if (day.weekday == DateTime.sunday) {
                                            final text = DateFormat.E().format(day);
                                            return Center(
                                              child: Text(
                                                "일",
                                                style: TextStyle(color: Colors.red),
                                              ),
                                            );
                                          }
                                      return Container(
                                        width: 50, // Increase width to give more space for the day headers
                                        alignment: Alignment.center,
                                        child: Text(
                                          text,
                                          style: TextStyle(
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
                                            DateFormat.yMMMM('ko_KR').format(day),
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    markerBuilder: (context, date, events) {
                                      if (events.isNotEmpty) {
                                        return Positioned(
                                          bottom: 2, // Adjust the position from the bottom
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Column(
                                              children: events.map((event) {
                                                final eventMap = event as Map<String, dynamic>;
                                                final numOfQuestions = eventMap['numOfQuestions'] ?? 0;
                                                final numOfCollectQuestions = eventMap['numOfCollectQuestions'] ?? 0;
                                                final type = eventMap['type'] ?? 'Unknown';

                                                return Container(
                                                  constraints: BoxConstraints(maxWidth: 60), // Constrain the width
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: type == '기본' ? Colors.blue : Colors.red,
                                                  ),
                                                  padding: EdgeInsets.all(3),
                                                  margin: EdgeInsets.symmetric(vertical: 0.5),
                                                  child: Text(
                                                    '$type: $numOfCollectQuestions/$numOfQuestions',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        );
                                      }
                                      return null;
                                    },
                                    defaultBuilder: (context, date, focusedDay) {
                                      return Container(
                                        margin: EdgeInsets.all(8.0),
                                        alignment: Alignment.topCenter, // Align the date to the top
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${date.day}',
                                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                                            ),
                                          ],
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
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                          margin: EdgeInsets.only(bottom: 40.0, top: 8.0, left: 8.0, right: 8.0),
                                          alignment: Alignment.center, // Align the date to the center
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${date.day}',
                                                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    selectedBuilder: (context, date, focusedDay) {
                                      bool isToday = date.year == DateTime.now().year &&
                                                    date.month == DateTime.now().month &&
                                                    date.day == DateTime.now().day;

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
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                margin: EdgeInsets.only(top: 8.0),
                                                alignment: Alignment.topCenter, // Align the date to the top
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      '${date.day}',
                                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Center(
                                                child:
                                                  Container(
                                                  width: 40.0,
                                                  height: 40.0,
                                                  decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                  margin: EdgeInsets.only(bottom: 40.0, top: 11.0, left: 8.0, right: 8.0),
                                                  alignment: Alignment.center, // Align the date to the center
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        '${date.day}',
                                                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]
                                          ),
                                        );
                                      } else{
                                        return Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: Colors.purple,
                                              ),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          margin: EdgeInsets.only(top: 8.0),
                                          alignment: Alignment.topCenter, // Align the date to the top
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${date.day}',
                                                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    outsideBuilder: (context, date, focusedDay) {
                                      return Container(
                                        margin: EdgeInsets.all(8.0),
                                        alignment: Alignment.topCenter, // Align the date to the top
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${date.day}',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    holidayBuilder: (context, date, focusedDay) {
                                      return Container(
                                        margin: EdgeInsets.all(8.0),
                                        alignment: Alignment.topCenter, // Align the date to the top
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${date.day}',
                                              style: TextStyle(fontSize: 18.0, color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              
                              SizedBox(height: 10), // Add some space between the calendar and the event details
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                  ),
                                padding: EdgeInsets.all(8),
                                child: selectedEvents.isNotEmpty
                                    ? ListView.builder(
                                        shrinkWrap: true, // Prevent the ListView from taking up unnecessary space
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: selectedEvents.length,
                                        itemBuilder: (context, index) {
                                          final event = selectedEvents[index];
                                          final type = event['type'];
                                          final numOfQuestions = event['numOfQuestions'];
                                          final numOfCollectQuestions = event['numOfCollectQuestions'];
                                          final ratio = (event['numOfQuestions'] == 0)
                                            ? "해당 훈련을 진행하지 않았습니다."
                                            : "정답률: " + (event['numOfCollectQuestions'] / event['numOfQuestions'] * 100).toStringAsFixed(2);

                                          return Container(
                                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: type == '기본' ? Colors.blue[100] : Colors.red[100],
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: type == '기본' ? Colors.blue : Colors.red),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Type: $type''훈련 결과', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                                Text('정답 수: $numOfCollectQuestions' '개', style: TextStyle(fontSize: 18)),
                                                Text('문제 수: $numOfQuestions' '개', style: TextStyle(fontSize: 18)),
                                                Text(ratio, style: TextStyle(fontSize: 18)),
                                              ],
                                            ),
                                          );
                                        },
                                      )
                                    : Center(
                                        child: Text('해당 날짜에는 훈련을 하지 않았습니다.'),
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