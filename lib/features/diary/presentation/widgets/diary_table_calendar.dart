import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/entity/tracked_day_entity.dart';
import 'package:opennutritracker/core/utils/extensions.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:opennutritracker/generated/l10n.dart';

class DiaryTableCalendar extends StatefulWidget {
  final Function(DateTime, Map<String, TrackedDayEntity>) onDateSelected;
  final Duration calendarDurationDays;
  final DateTime focusedDate;
  final DateTime currentDate;
  final DateTime selectedDate;

  final Map<String, TrackedDayEntity> trackedDaysMap;

  const DiaryTableCalendar(
      {super.key,
      required this.onDateSelected,
      required this.calendarDurationDays,
      required this.focusedDate,
      required this.currentDate,
      required this.selectedDate,
      required this.trackedDaysMap});

  @override
  State<DiaryTableCalendar> createState() => _DiaryTableCalendarState();
}

class _DiaryTableCalendarState extends State<DiaryTableCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      headerStyle:
          const HeaderStyle(formatButtonVisible: true),
      calendarFormat: _calendarFormat,
      availableCalendarFormats: {
        CalendarFormat.month: '${S.of(context).monthLabel} ▼',
        CalendarFormat.week: '${S.of(context).weekLabel} ▲',
      },
      onFormatChanged: (format) {
        setState(() {
          _calendarFormat = format;
        });
      },
      focusedDay: widget.focusedDate,
      firstDay: widget.currentDate.subtract(widget.calendarDurationDays),
      lastDay: widget.currentDate.add(widget.calendarDurationDays),
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: (selectedDay, focusedDay) {
        widget.onDateSelected(selectedDay, widget.trackedDaysMap);
      },
      calendarStyle: CalendarStyle(
          markersMaxCount: 1,
          todayTextStyle:
              Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
          todayDecoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 2.0),
              shape: BoxShape.circle),
          selectedTextStyle: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onPrimary) ??
              const TextStyle(),
          selectedDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle)),
      selectedDayPredicate: (day) => isSameDay(widget.selectedDate, day),
      calendarBuilders:
          CalendarBuilders(
            markerBuilder:
              (context, date, events) {
                final trackedDay = widget.trackedDaysMap[date.toParsedDay()];
                if (trackedDay != null) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.primary),
                    width: 5.0,
                    height: 5.0,
                  );
                } else {
                  return const SizedBox();
                }
              },
            headerTitleBuilder:
              (context, day) {
                return Text(
                  _calendarFormat == CalendarFormat.month ?
                    DateFormat(DateFormat.YEAR_ABBR_MONTH).format(day) :
                    _getFormattedSelectedDateString(context, widget.focusedDate),
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.titleLarge,
                );
              },
          ),
    );
  }

  String _getFormattedSelectedDateString(BuildContext context, DateTime selectedDay) {
    final DateTime today = DateTime.now();
    final DateTime yesterday = today.subtract(const Duration(days: 1));
    final DateTime tomorrow = today.add(const Duration(days: 1));
    if (DateUtils.isSameDay(selectedDay, yesterday)) {
      return S.of(context).dateYesterdayLabel;
    } else if (DateUtils.isSameDay(selectedDay, today)) {
      return S.of(context).dateTodayLabel;
    } else if (DateUtils.isSameDay(selectedDay, tomorrow)) {
      return S.of(context).dateTomorrowLabel;
    }
    // Otherwise, just return the formatted full date string
    return DateFormat(DateFormat.ABBR_MONTH_WEEKDAY_DAY).format(selectedDay);
  }
}
