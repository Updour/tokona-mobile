import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarService {
  CalendarService._();

  static String _formatUtc(DateTime dt) {
    final utc = dt.toUtc();
    return '${utc.year.toString().padLeft(4, '0')}'
        '${utc.month.toString().padLeft(2, '0')}'
        '${utc.day.toString().padLeft(2, '0')}T'
        '${utc.hour.toString().padLeft(2, '0')}'
        '${utc.minute.toString().padLeft(2, '0')}'
        '${utc.second.toString().padLeft(2, '0')}Z';
  }

  static Future<bool> addEventToCalendar({
    required String title,
    required String description,
    required DateTime plannedDate,
    String? location,
  }) async {
    final start = DateTime(plannedDate.year, plannedDate.month, plannedDate.day, 9, 0);
    final end = start.add(const Duration(hours: 1));

    final datesParam = '${_formatUtc(start)}/${_formatUtc(end)}';
    final queryParams = <String, String>{
      'action': 'TEMPLATE',
      'text': title,
      'dates': datesParam,
      'details': description,
    };

    if (location != null && location.isNotEmpty) {
      queryParams['location'] = location;
    }

    final calendarUri = Uri.https('calendar.google.com', '/calendar/render', queryParams);

    try {
      return await launchUrl(calendarUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('CalendarService: failed to launch calendar: $e');
      return false;
    }
  }
}

