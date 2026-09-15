import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Shorthand for `AppLocalizations.of(context)!`.
/// Usage inside any widget with a BuildContext: `context.l10n.someKey`.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
