import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:intl/intl.dart' hide TextDirection;

import '../../l10n/generated/easy_date_timeline_localizations.dart';
import '../disable_strategy/strategies.dart';
import '../enums/enums.exports.dart';
import '../utils/utils.exports.dart';
import 'easy_date_picker_mode_toggle_button.dart';
import 'month_picker/easy_month_picker_view.dart';
import 'year_picker/easy_year_picker.dart';

const Size _calendarPortraitDialogSizeM2 = Size(330.0, 518.0);
const Size _calendarPortraitDialogSizeM3 = Size(328.0, 512.0);
const Size _calendarLandscapeDialogSize = Size(496.0, 346.0);
const Duration _dialogSizeAnimationDuration = Duration(milliseconds: 200);
const double _kMaxTextScaleFactor = 1.3;

/// Displays a dialog that allows the user to pick a month and year.
///
/// The [context] parameter is required and specifies the build context to use.
/// The [focusDate] parameter specifies the initial date to focus on when the picker is shown.
/// The [firstDate] parameter specifies the earliest date that can be selected.
/// The [lastDate] parameter specifies the latest date that can be selected.
/// The [currentDate] parameter specifies the current date, which is used to highlight the current day.
/// The [initialCalendarMode] parameter specifies the initial display mode of the calendar (month or year).
/// The [cancelText] parameter specifies the text for the cancel button.
/// The [confirmText] parameter specifies the text for the confirm button.
/// The [locale] parameter specifies the locale to use for the picker.
/// The [barrierDismissible] parameter specifies whether the dialog can be dismissed by tapping outside of it.
/// The [barrierColor] parameter specifies the color of the modal barrier that darkens everything below the dialog.
/// The [barrierLabel] parameter specifies the semantic label for the modal barrier.
/// The [useRootNavigator] parameter specifies whether to use the root navigator.
/// The [routeSettings] parameter specifies the settings for the route.
/// The [textDirection] parameter specifies the text direction for the dialog.
/// The [builder] parameter allows customization of the dialog widget.
/// The [onDatePickerModeChange] parameter is a callback that is called when the date picker mode changes.
/// The [disableStrategy] parameter specifies the strategy to use for disabling dates.
///
/// Returns a [Future] that resolves to the selected [DateTime], or null if the dialog was canceled.

Future<DateTime?> showMonthYearPicker({
  required BuildContext context,
  DateTime? focusDate,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? currentDate,
  EasyDatePickerMode initialCalendarMode = EasyDatePickerMode.month,
  String? cancelText,
  String? confirmText,
  Locale? locale,
  bool barrierDismissible = true,
  Color? barrierColor,
  String? barrierLabel,
  bool useRootNavigator = true,
  RouteSettings? routeSettings,
  TextDirection? textDirection,
  TransitionBuilder? builder,
  final ValueChanged<EasyDatePickerMode>? onDatePickerModeChange,
  required DisableStrategy disableStrategy,
}) async {
  focusDate = focusDate == null ? null : DateUtils.dateOnly(focusDate);
  firstDate = DateUtils.dateOnly(firstDate);
  lastDate = DateUtils.dateOnly(lastDate);
  assert(
    !lastDate.isBefore(firstDate),
    'lastDate $lastDate must be on or after firstDate $firstDate.',
  );
  assert(
    focusDate == null || !focusDate.isBefore(firstDate),
    'focusDate $focusDate must be on or after firstDate $firstDate.',
  );
  assert(
    focusDate == null || !focusDate.isAfter(lastDate),
    'initialDate $focusDate must be on or before lastDate $lastDate.',
  );

  Widget dialog = MonthYearPicker(
    focusDate: focusDate,
    firstDate: firstDate,
    lastDate: lastDate,
    currentDate: currentDate,
    locale: locale,
    disableStrategy: disableStrategy,
    cancelText: cancelText,
    confirmText: confirmText,
    initialCalendarMode: initialCalendarMode,
  );

  if (textDirection != null) {
    dialog = Directionality(
      textDirection: textDirection,
      child: dialog,
    );
  }

  if (locale != null) {
    dialog = Localizations.override(
      context: context,
      locale: locale,
      child: dialog,
    );
  }
  return showDialog<DateTime>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: barrierColor,
    barrierLabel: barrierLabel,
    useRootNavigator: useRootNavigator,
    routeSettings: routeSettings,
    builder: (BuildContext context) {
      return builder == null ? dialog : builder(context, dialog);
    },
  );
}

class MonthYearPicker extends StatefulWidget {
  /// A widget that provides a month and year picker dialog.
  ///
  /// The [MonthYearPicker] widget allows users to select a month and year within
  /// a specified date range. It supports different calendar modes (month and year)
  /// and provides customization options for localization, button texts, and disable
  /// strategies.
  ///
  /// The widget requires [firstDate] and [lastDate] to define the selectable date range.
  /// Optionally, a [focusDate] can be provided to set the initial focused date, and
  /// [currentDate] can be used to specify the current date.
  ///
  /// The [MonthYearPicker] widget also supports restoration with the [restorationId]
  /// parameter and localization with the [locale] parameter.
  ///
  /// The [disableStrategy] parameter allows specifying a strategy to disable certain
  /// dates, and [cancelText] and [confirmText] can be used to customize the button texts.
  ///
  /// The initial calendar mode can be set using the [initialCalendarMode] parameter.
  ///
  /// Example usage:
  /// ```dart
  /// MonthYearPicker(
  ///   firstDate: DateTime(2020, 1),
  ///   lastDate: DateTime(2025, 12),
  ///   focusDate: DateTime(2022, 6),
  ///   currentDate: DateTime.now(),
  ///   cancelText: 'Cancel',
  ///   confirmText: 'OK',
  ///   initialCalendarMode: EasyDatePickerMode.month,
  /// )
  /// ```
  ///
  /// See also:
  /// - [EasyMonthPickerView], which displays the month picker.
  /// - [EasyYearPicker], which displays the year picker.
  /// - [EasyDatePickerMode], which defines the calendar modes.

  MonthYearPicker({
    super.key,
    DateTime? focusDate,
    required DateTime firstDate,
    required DateTime lastDate,
    DateTime? currentDate,
    this.restorationId,
    Locale? locale,
    this.disableStrategy = const DisableStrategy.none(),
    this.cancelText,
    this.confirmText,
    this.initialCalendarMode = EasyDatePickerMode.month,
  })  : focusDate = focusDate == null ? null : DateUtils.dateOnly(focusDate),
        firstDate = DateUtils.dateOnly(firstDate),
        lastDate = DateUtils.dateOnly(lastDate),
        currentDate = DateUtils.dateOnly(currentDate ?? DateTime.now()),
        _locale = locale?.toLanguageTag() {
    assert(
      !this.lastDate.isBefore(this.firstDate),
      'lastDate ${this.lastDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      focusDate == null || !this.focusDate!.isBefore(this.firstDate),
      'initialDate ${this.focusDate} must be on or after firstDate ${this.firstDate}.',
    );
    assert(
      focusDate == null || !this.focusDate!.isAfter(this.lastDate),
      'initialDate ${this.focusDate} must be on or before lastDate ${this.lastDate}.',
    );
  }

  /// The initially focused date when the picker is first displayed
  final DateTime? focusDate;

  /// The earliest allowable date
  final DateTime firstDate;

  /// The latest allowable date
  final DateTime lastDate;

  /// The current date, typically used to highlight today's date
  final DateTime currentDate;

  /// Restoration ID used for state restoration
  final String? restorationId;

  /// The locale used for formatting dates
  final String? _locale;

  /// Strategy to determine which dates/months should be disabled
  final DisableStrategy disableStrategy;

  /// Custom text for the cancel button. If null, uses localized 'Cancel'
  final String? cancelText;

  /// Custom text for the confirm button. If null, uses localized 'OK'
  final String? confirmText;

  /// The initial calendar mode (month or year view) when the picker is displayed
  final EasyDatePickerMode initialCalendarMode;

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late EasyDatePickerMode _mode;
  late DateTime _selectedDate;
  final GlobalKey _monthPickerKey = GlobalKey();
  final GlobalKey _yearPickerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialCalendarMode;
    _selectedDate = widget.focusDate ?? widget.firstDate;
  }

  /// Handles the OK button press, returning the selected date
  void _handleOk() {
    Navigator.pop(context, _selectedDate);
  }

  /// Handles the Cancel button press, dismissing the dialog
  void _handleCancel() {
    Navigator.pop(context);
  }

  /// Determines the size of the dialog based on orientation and theme
  Size _dialogSize(BuildContext context) {
    final bool useMaterial3 = Theme.of(context).useMaterial3;
    final Orientation orientation = MediaQuery.orientationOf(context);
    return switch ((orientation)) {
      (Orientation.portrait) when useMaterial3 => _calendarPortraitDialogSizeM3,
      (Orientation.portrait) => _calendarPortraitDialogSizeM2,
      (Orientation.landscape) => _calendarLandscapeDialogSize,
    };
  }

  /// Triggers haptic feedback based on platform
  void _vibrate() {
    switch (Theme.of(context).platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        HapticFeedback.vibrate();
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        break;
    }
  }

  /// Handles switching between month and year modes
  void _handleModeChanged(EasyDatePickerMode mode) {
    _vibrate();
    setState(() {
      _mode = mode;
    });
  }

  /// Updates the selected date when a new date is chosen
  void _handleDateChanged(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  /// Handles the change of the year in the date picker.
  ///
  /// This method is triggered when the user selects a different year.
  /// It updates the picker mode to month selection and adjusts the selected
  /// date to the first day of the selected year while ensuring the new date
  /// is within the bounds of `firstDate` and `lastDate`.
  ///
  /// If the new date is before `firstDate`, it adjusts to the month and day
  /// of `firstDate`. If the new date is after `lastDate`, it adjusts to the
  /// month and day of `lastDate`, and if still out of bounds, it sets the date
  /// to the previous year.
  ///
  /// Parameters:
  /// - `date`: The new date with the selected year.
  void _handleYearChanged(DateTime date) {
    _vibrate();
    _mode = EasyDatePickerMode.month;
    DateTime newDate = DateTime(date.year, _selectedDate.month, 1);
    if (newDate.isBefore(widget.firstDate)) {
      newDate =
          DateTime(date.year, widget.firstDate.month, widget.firstDate.day);
    } else if (newDate.isAfter(widget.lastDate)) {
      newDate = DateTime(date.year, widget.lastDate.month, 1);
      if (newDate.isAfter(widget.lastDate)) {
        newDate =
            DateTime(date.year - 1, widget.lastDate.month, widget.lastDate.day);
      }
    }

    // Ensure the day is valid for the new month
    final lastDayOfMonth = DateTime(newDate.year, newDate.month + 1, 0).day;
    if (newDate.day > lastDayOfMonth) {
      newDate = DateTime(newDate.year, newDate.month, lastDayOfMonth);
    }
    _handleDateChanged(newDate);
  }

  /// Builds either the month or year picker view based on current mode
  Widget _buildPicker() {
    return switch (_mode) {
      EasyDatePickerMode.month => EasyMonthPickerView(
          key: _monthPickerKey,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          focusedDate: _selectedDate,
          currentDate: widget.currentDate,
          onChanged: _handleDateChanged,
          onYearPageChanged: _handleYearChanged,
          locale: widget._locale,
          disableStrategy: widget.disableStrategy,
        ),
      EasyDatePickerMode.year => EasyYearPicker(
          key: _yearPickerKey,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          focusedDate: _selectedDate,
          currentDate: widget.currentDate,
          onChanged: _handleYearChanged,
          dragStartBehavior: DragStartBehavior.start,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final localizations = EasyDateTimelineLocalizations.of(context);
    final DatePickerThemeData datePickerTheme = DatePickerTheme.of(context);
    final DatePickerThemeData defaults = DatePickerTheme.defaults(context);
    // Constrain the textScaleFactor to the largest supported value to prevent
    // layout issues.
    // 14 is a common font size used to compute the effective text scale.
    const double fontSizeToScale = 14.0;
    final double textScaleFactor = MediaQuery.textScalerOf(context)
            .clamp(maxScaleFactor: _kMaxTextScaleFactor)
            .scale(fontSizeToScale) /
        fontSizeToScale;
    final Size dialogSize = _dialogSize(context) * textScaleFactor;
    final DialogTheme dialogTheme = theme.dialogTheme;
    final Widget header = EasyDatePickerModeToggleButton(
      mode: _mode,
      title: DateFormat(DateFormatUtils.monthY, widget._locale)
          .format(_selectedDate),
      onTitlePressed: () => _handleModeChanged(switch (_mode) {
        EasyDatePickerMode.month => EasyDatePickerMode.year,
        EasyDatePickerMode.year => EasyDatePickerMode.month,
      }),
    );

    final Widget actions = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Align(
          alignment: AlignmentDirectional.centerEnd,
          child: OverflowBar(
            spacing: 8,
            children: <Widget>[
              TextButton(
                style: datePickerTheme.cancelButtonStyle ??
                    defaults.cancelButtonStyle,
                onPressed: _handleCancel,
                child: Text(widget.cancelText ??
                    ((useMaterial3
                            ? localizations?.cancelButtonLabel
                            : localizations?.cancelButtonLabel.toUpperCase()) ??
                        cancelButtonLabel)),
              ),
              TextButton(
                style: datePickerTheme.confirmButtonStyle ??
                    defaults.confirmButtonStyle,
                onPressed: _handleOk,
                child: Text(widget.confirmText ??
                    localizations?.okButtonLabel ??
                    okButtonLabel),
              ),
            ],
          ),
        ),
      ),
    );

    return Dialog(
      backgroundColor:
          datePickerTheme.backgroundColor ?? defaults.backgroundColor,
      elevation: useMaterial3
          ? datePickerTheme.elevation ?? defaults.elevation!
          : datePickerTheme.elevation ?? dialogTheme.elevation ?? 24,
      shadowColor: datePickerTheme.shadowColor ?? defaults.shadowColor,
      surfaceTintColor:
          datePickerTheme.surfaceTintColor ?? defaults.surfaceTintColor,
      shape: useMaterial3
          ? datePickerTheme.shape ?? defaults.shape
          : datePickerTheme.shape ?? dialogTheme.shape ?? defaults.shape,
      insetPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      clipBehavior: Clip.antiAlias,
      child: AnimatedContainer(
        width: dialogSize.width,
        height: dialogSize.width,
        //height: dialogSize.height,
        duration: _dialogSizeAnimationDuration,
        curve: Curves.easeIn,
        child: MediaQuery.withClampedTextScaling(
          // Constrain the textScaleFactor to the largest supported value to prevent
          // layout issues.
          maxScaleFactor: _kMaxTextScaleFactor,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: <Widget>[
                    header,
                    _buildPicker(),
                  ],
                ),
              ),
              actions,
            ],
          ),
        ),
      ),
    );
  }
}
