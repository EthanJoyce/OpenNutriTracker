import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:file_picker/file_picker.dart';
import 'package:android_file_picker/android_file_picker.dart';
import 'package:opennutritracker/core/tasks/auto_backup_task.dart';
import 'package:opennutritracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:opennutritracker/generated/l10n.dart';
import 'package:saf_util/saf_util.dart';

class AutomaticBackupDialog extends StatefulWidget {
  final SettingsBloc settingsBloc;

  const AutomaticBackupDialog({
    super.key,
    required this.settingsBloc,
  });

  @override
  State<AutomaticBackupDialog> createState() => _AutomaticBackupDialogState();
}

class _AutomaticBackupDialogState extends State<AutomaticBackupDialog> {
  final log = Logger('_AutomaticBackupDialogState');

  static final dateFormat = DateFormat("MMM d, yyy hh:mm a");

  static const bool _backupsEnabledDefault = false;
  static const String? _backupLocationDefault = null;
  static const BackupIntervalDropDownType _backupIntervalDefault = BackupIntervalDropDownType.weekly;
  static const BackupBehaviorDropDownType _backupBehaviorDefault = BackupBehaviorDropDownType.overwrite;

  bool _backupSupported = true; // Not all devices support auto-backup yet

  bool _backupsEnabled = _backupsEnabledDefault;
  String? _backupLocation = _backupLocationDefault;
  BackupIntervalDropDownType _backupInterval = _backupIntervalDefault;
  BackupBehaviorDropDownType _backupBehavior = _backupBehaviorDefault;

  DateTime? _lastBackupDate;

  @override
  void initState() {
    super.initState();

    initAutoBackupState();
  }

  void initAutoBackupState() async {
    // The background task isolate writes to this same box, so reload the
    // in-memory keystore from disk before reading to ensure we see any
    // backup that ran while the app was alive.
    await widget.settingsBloc.reloadBackupInfo();

    final bool backupSupported = Platform.isAndroid;
  
    final bool backupsEnabled = await widget.settingsBloc.getAutoBackupEnabled();
    final String? backupLocation = await widget.settingsBloc.getAutoBackupLocation();
    final BackupIntervalDropDownType backupInterval = getBackupIntervalEnumFromValue(await widget.settingsBloc.getAutoBackupIntervalDays() ?? 0) ?? _backupIntervalDefault;
    final BackupBehaviorDropDownType backupBehavior = (await widget.settingsBloc.getAutoBackupOverwrite()) ? BackupBehaviorDropDownType.overwrite : BackupBehaviorDropDownType.createNew;

    final DateTime? lastBackupDate = await widget.settingsBloc.getLastBackupTimestamp();

    setState(() {
      _backupSupported = backupSupported;

      _backupsEnabled = backupsEnabled;
      _backupLocation = backupLocation;
      _backupInterval = backupInterval;
      _backupBehavior = backupBehavior;

      _lastBackupDate = lastBackupDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              S.of(context).automaticBackupLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8), // Add spacing between text and button
          TextButton(
            child: Text(S.of(context).buttonResetLabel),
            onPressed: () {
              setState(() {
                // Reset macros to default values
                _backupsEnabled = _backupsEnabledDefault;
                _backupLocation = _backupLocationDefault;
                _backupInterval = _backupIntervalDefault;
                _backupBehavior = _backupBehaviorDefault;
              });
            },
          ),
        ],
      ),
      content: Wrap(
        children: [
          Visibility(
            visible: !_backupSupported,
            child:
              ListTile(
                leading: const Icon(Icons.warning),
                title: Text(S.of(context).backupNotSupportedLabel),
              ),
          ),
          SwitchListTile(
            title: Text(S.of(context).enableAutomaticBackupLabel),
            value: _backupsEnabled,
            onChanged:
              _backupSupported ?
                (bool value) {
                  setState(() {
                    _backupsEnabled = value;
                  });
                }
              : null,
          ),
          Visibility(
            visible: _backupsEnabled,
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.folder),
                  title: Text(S.of(context).backupLocationLabel),
                  subtitle: Text(_backupLocation ?? S.of(context).backupNotSetLabel),
                  onTap: () => _selectBackupLocation(),
                ),
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: DropdownButtonFormField(
                    initialValue: _backupInterval,
                    decoration: InputDecoration(
                      enabled: true,
                      filled: false,
                      labelText: S.of(context).backupIntervalLabel,
                    ),
                    onChanged: (value) {
                      _backupInterval = value ?? BackupIntervalDropDownType.weekly;
                    },
                    items: [
                      DropdownMenuItem(
                          value: BackupIntervalDropDownType.daily,
                          child: Text(S.of(context).backupIntervalDailyLabel)),
                      DropdownMenuItem(
                          value: BackupIntervalDropDownType.weekly,
                          child: Text(S.of(context).backupIntervalWeeklyLabel)),
                      DropdownMenuItem(
                          value: BackupIntervalDropDownType.monthly,
                          child: Text(S.of(context).backupIntervalMonthlyLabel))
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.swap_horiz),
                  title: DropdownButtonFormField(
                    initialValue: _backupBehavior,
                    decoration: InputDecoration(
                      enabled: true,
                      filled: false,
                      labelText: S.of(context).backupBehaviorLabel,
                    ),
                    onChanged: (value) {
                      _backupBehavior = value ?? _backupBehaviorDefault;
                    },
                    items: [
                      DropdownMenuItem(
                          value: BackupBehaviorDropDownType.overwrite,
                          child: Text(S.of(context).backupBehaviorOverwriteLabel)),
                      DropdownMenuItem(
                          value: BackupBehaviorDropDownType.createNew,
                          child: Text(S.of(context).backupBehaviorCreateNewLabel)),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(S.of(context).backupStatusLabel),
                  subtitle: Wrap(
                    direction: Axis.vertical,
                    children: [
                      Text("${S.of(context).backupStatusLastBackupLabel} ${_lastBackupDate != null ? dateFormat.format(_lastBackupDate!) : S.of(context).backupStatusNeverLabel}"),
                    ]
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.save),
                  title: OutlinedButton(
                    child: Text(S.of(context).backupNowLabel),
                    onPressed: () {
                      runImmediateAutoBackupTask();
                      _saveSettings();
                      Navigator.of(context).pop();
                    }
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogCancelLabel)),
        TextButton(
            onPressed: () {
              _saveSettings();
              Navigator.of(context).pop();
            },
            child: Text(S.of(context).dialogOKLabel))
      ],
    );
  }

  void _selectBackupLocation() async {
    final location = await FilePicker.getDirectoryPath(
      dialogTitle: S.of(context).backupLocationLabel,
      initialDirectory: _backupLocation,
      androidOptions: const FilePickerAndroidOptions(
        safOptions: AndroidSAFOptions(
          grant: AndroidSAFGrant.lifetime,
          accessMode: AndroidSAFAccessMode.readWrite,
          persistGrant: true,
        )
      )
    );
    if (Platform.isAndroid && (_backupLocation != null) && (location != _backupLocation)) {
      // On Android, we should release the old SAF permission
      await SafUtil().releasePersistedPermission(_backupLocation!, read: true, write: true);
    }
    setState(() {
      _backupLocation = location;
    });
    log.fine("Updated backup location: $location");
  }

  void _saveSettings() async {
    final int? backupIntervalDays = getBackupIntervalValueFromEnum(_backupInterval);
    final bool backupOverwrite = _backupBehavior == BackupBehaviorDropDownType.overwrite;
    await widget.settingsBloc
        .setAutoBackupConfig(_backupsEnabled, _backupLocation, backupIntervalDays, backupOverwrite);
    widget.settingsBloc.add(LoadSettingsEvent());

    refreshAutoBackupTask(_backupsEnabled, backupIntervalDays);
  }
}
