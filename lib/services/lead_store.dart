import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' as xl;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// The apartment a visitor registered interest in.
class InterestTarget {
  const InterestTarget({
    required this.buildingType,
    required this.unitType,
    required this.source,
    this.buildingId,
    this.floor,
  });

  /// Building type letter, e.g. "A".
  final String buildingType;

  /// Apartment type id, e.g. "2BR".
  final String unitType;

  /// Where the form was opened: [fromApartmentDetails] or [fromCompare].
  final String source;

  /// Building id (e.g. "A03"); null for an apartment picked by type in the comparison.
  final String? buildingId;

  /// Floor code (e.g. "3F"); null when the apartment is not on a chosen floor.
  final String? floor;

  static const fromApartmentDetails = 'apartment_details';
  static const fromCompare = 'compare';
}

/// One Register Interest submission.
class Lead {
  const Lead({
    required this.time,
    required this.name,
    required this.email,
    required this.phone,
    required this.language,
    this.target,
  });

  final DateTime time;
  final String name;
  final String email;

  /// Country code and number, e.g. "+966 512345678".
  final String phone;

  /// Language the visitor used ("en" or "ar").
  final String language;
  final InterestTarget? target;

  Map<String, Object?> toJson() => {
        'time': time.toIso8601String(),
        'name': name,
        'email': email,
        'phone': phone,
        'language': language,
        if (target case final t?) ...{
          'buildingType': t.buildingType,
          'unitType': t.unitType,
          'source': t.source,
          'building': ?t.buildingId,
          'floor': ?t.floor,
        },
      };

  factory Lead.fromJson(Map<String, dynamic> json) => Lead(
        time: DateTime.parse(json['time'] as String),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        language: json['language'] as String? ?? '',
        target: json['buildingType'] == null
            ? null
            : InterestTarget(
                buildingType: json['buildingType'] as String,
                unitType: json['unitType'] as String? ?? '',
                source: json['source'] as String? ?? '',
                buildingId: json['building'] as String?,
                floor: json['floor'] as String?,
              ),
      );
}

/// Keeps every Register Interest submission on the tablet, in a `leads` folder:
///
/// - [logName]: the record, one JSON object per line, only ever appended to,
///   so a crash or a full disk never loses earlier leads;
/// - [sheetName]: the same leads as a spreadsheet (every cell text, so phone
///   numbers keep their `+` and leading zeros, Arabic names show in Excel),
///   rebuilt from the record after each submission. Copy it off the tablet to
///   work on it; edits made in place are replaced by the next submission.
///
/// On Android the folder is in the app's external files
/// (`Android/data/<app id>/files/leads`), which a computer can open over USB;
/// elsewhere it is in the app documents folder. Nothing is sent anywhere.
class LeadStore {
  LeadStore({Future<Directory> Function()? directory}) : _directory = directory ?? _defaultDirectory;

  /// The app's store; tests replace it with one on a temporary folder.
  static LeadStore instance = LeadStore();

  static const logName = 'register_interest.jsonl';
  static const sheetName = 'register_interest.xlsx';

  final Future<Directory> Function() _directory;

  /// Submissions are written one at a time, in order.
  Future<void> _queue = Future.value();

  static Future<Directory> _defaultDirectory() async {
    Directory? base;
    if (Platform.isAndroid) base = await getExternalStorageDirectory();
    base ??= await getApplicationDocumentsDirectory();
    return Directory('${base.path}${Platform.pathSeparator}leads');
  }

  /// The folder holding [logName] and [sheetName].
  Future<Directory> get directory => _directory();

  /// Saves [lead]. Completes once it is in the record; throws when it could
  /// not be written (the visitor is then asked to try again).
  Future<void> add(Lead lead) {
    final done = _queue.then((_) => _add(lead));
    _queue = done.catchError((Object _) {});
    return done;
  }

  Future<void> _add(Lead lead) async {
    final dir = await _directory();
    await dir.create(recursive: true);
    final log = File(_path(dir, logName));
    // After a line cut short (power lost mid-write), start a new one, so only
    // that line is lost.
    final newLine = await _endsMidLine(log) ? '\n' : '';
    await log.writeAsString('$newLine${jsonEncode(lead.toJson())}\n', mode: FileMode.append, flush: true);
    // The lead is safe in the record; a failed spreadsheet is rebuilt with
    // the next submission.
    try {
      await _writeSheet(dir, await _read(log));
    } catch (error) {
      debugPrint('LeadStore: could not write $sheetName: $error');
    }
  }

  /// Every saved lead, oldest first.
  Future<List<Lead>> readAll() async {
    final log = File(_path(await _directory(), logName));
    return await log.exists() ? _read(log) : const [];
  }

  static Future<List<Lead>> _read(File log) async => [
        for (final line in await log.readAsLines()) ?_parse(line),
      ];

  static Future<bool> _endsMidLine(File log) async {
    if (!await log.exists()) return false;
    final file = await log.open();
    try {
      final length = await file.length();
      if (length == 0) return false;
      await file.setPosition(length - 1);
      return await file.readByte() != 0x0A;
    } finally {
      await file.close();
    }
  }

  /// A line cut short (e.g. power lost mid-write) is skipped, not fatal.
  static Lead? _parse(String line) {
    if (line.trim().isEmpty) return null;
    try {
      return Lead.fromJson(jsonDecode(line) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Written next to the spreadsheet and moved over it, so a reader never
  /// sees half a file.
  static Future<void> _writeSheet(Directory dir, List<Lead> leads) async {
    final temp = File(_path(dir, '$sheetName.tmp'));
    await temp.writeAsBytes(buildSheet(leads), flush: true);
    await temp.rename(_path(dir, sheetName));
  }

  static String _path(Directory dir, String name) => '${dir.path}${Platform.pathSeparator}$name';

  /// Column headings (English: the sheet is for the sales team) and widths.
  static const columns = [
    ('Submitted', 20.0),
    ('Name', 28.0),
    ('Email', 32.0),
    ('Phone', 20.0),
    ('Language', 10.0),
    ('Building', 10.0),
    ('Building Type', 14.0),
    ('Floor', 8.0),
    ('Apartment Type', 16.0),
    ('Source', 18.0),
  ];

  /// The spreadsheet (.xlsx bytes) for [leads]: a header row, then one row per lead.
  @visibleForTesting
  static List<int> buildSheet(List<Lead> leads) {
    final book = xl.Excel.createExcel();
    final defaultSheet = book.getDefaultSheet()!;
    const name = 'Leads';
    book.rename(defaultSheet, name);
    final sheet = book[name];
    final bold = xl.CellStyle(bold: true);
    for (var c = 0; c < columns.length; c++) {
      sheet.updateCell(
        xl.CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0),
        xl.TextCellValue(columns[c].$1),
        cellStyle: bold,
      );
      sheet.setColumnWidth(c, columns[c].$2);
    }
    for (final lead in leads) {
      final t = lead.target;
      sheet.appendRow([
        for (final value in [
          _timestamp(lead.time),
          lead.name,
          lead.email,
          lead.phone,
          lead.language,
          t?.buildingId,
          t?.buildingType,
          t?.floor,
          t?.unitType,
          t?.source,
        ])
          value == null || value.isEmpty ? null : xl.TextCellValue(value),
      ]);
    }
    return book.encode()!;
  }

  /// Local time as "2026-11-25 14:03:05": sorts as text and reads at a glance.
  static String _timestamp(DateTime time) {
    final t = time.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} ${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}
