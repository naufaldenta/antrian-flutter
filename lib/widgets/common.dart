import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../core/theme.dart';
import '../data/models.dart';

Future<T?> pushPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(CupertinoPageRoute(builder: (_) => page));

class IosPage extends StatelessWidget {
  const IosPage({
    super.key,
    required this.title,
    required this.children,
    this.large = true,
    this.trailing,
    this.leading,
    this.previousPageTitle,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 32),
  });

  final String title;
  final List<Widget> children;
  final bool large;
  final Widget? trailing;
  final Widget? leading;
  final String? previousPageTitle;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final back = canPop ? (previousPageTitle ?? 'Kembali') : null;
    final content = Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );

    if (!large) {
      return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text(title),
          trailing: trailing,
          leading: leading,
          previousPageTitle: back,
          transitionBetweenRoutes: false,
          backgroundColor: const Color(0xF0F9F9F9),
        ),
        body: SingleChildScrollView(
          child: SafeArea(top: false, child: content),
        ),
      );
    }
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(title),
            trailing: trailing,
            leading: leading,
            previousPageTitle: back,
            transitionBetweenRoutes: false,
            backgroundColor: AppColors.groupedBackground.withValues(
              alpha: 0.94,
            ),
            border: null,
          ),
          SliverSafeArea(
            top: false,
            sliver: SliverToBoxAdapter(child: content),
          ),
        ],
      ),
    );
  }
}

class IosSection extends StatelessWidget {
  const IosSection({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.dividerIndent = 16,
    this.topGap = 22,
  });

  final String? header;
  final Widget? footer;
  final List<Widget> children;
  final double dividerIndent;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i < children.length - 1) {
        rows.add(
          Container(
            height: 0.5,
            margin: EdgeInsets.only(left: dividerIndent),
            color: AppColors.separator,
          ),
        );
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: EdgeInsets.fromLTRB(16, topGap, 16, 7),
            child: Text(header!.toUpperCase(), style: AppText.footnote),
          )
        else
          SizedBox(height: topGap),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: AppColors.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rows,
            ),
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 7, 16, 0),
            child: DefaultTextStyle(style: AppText.footnote, child: footer!),
          ),
      ],
    );
  }
}

class IosRow extends StatefulWidget {
  const IosRow({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
    this.showChevron,
    this.titleColor,
    this.titleCentered = false,
    this.enabled = true,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? showChevron;
  final Color? titleColor;
  final bool titleCentered;
  final bool enabled;

  @override
  State<IosRow> createState() => _IosRowState();
}

class _IosRowState extends State<IosRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tappable = widget.onTap != null && widget.enabled;
    final chevron = widget.showChevron ?? (tappable && widget.trailing == null);
    final titleStyle = AppText.body.copyWith(
      color: widget.enabled ? widget.titleColor : AppColors.tertiaryLabel,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: tappable ? (_) => setState(() => _pressed = true) : null,
      onTapCancel: tappable ? () => setState(() => _pressed = false) : null,
      onTapUp: tappable ? (_) => setState(() => _pressed = false) : null,
      onTap: tappable ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? AppColors.pressed : AppColors.card,
        constraints: const BoxConstraints(minHeight: 46),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            if (widget.leading != null) ...[
              widget.leading!,
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: widget.titleCentered
                    ? CrossAxisAlignment.center
                    : CrossAxisAlignment.start,
                children: [
                  Text(widget.title, style: titleStyle),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(widget.subtitle!, style: AppText.subhead),
                  ],
                ],
              ),
            ),
            if (widget.value != null) ...[
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.value!,
                  textAlign: TextAlign.right,
                  style: AppText.body.copyWith(color: AppColors.secondaryLabel),
                ),
              ),
            ],
            if (widget.trailing != null) ...[
              const SizedBox(width: 8),
              widget.trailing!,
            ],
            if (chevron) ...[
              const SizedBox(width: 6),
              const Icon(
                CupertinoIcons.chevron_forward,
                size: 17,
                color: Color(0xFFC4C4C7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.footnote),
          const SizedBox(height: 2),
          Text(value, style: AppText.body),
        ],
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, required this.color, this.size = 30});

  final IconData icon;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.23),
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.6),
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.icon,
    required this.color,
    required this.category,
    this.trailingText,
    required this.child,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final String category;
  final String? trailingText;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      pressedOpacity: onTap == null ? 1 : 0.7,
      onPressed: onTap ?? () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 19),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    category,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.subhead.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (trailingText != null)
                  Text(trailingText!, style: AppText.footnote),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    CupertinoIcons.chevron_forward,
                    size: 14,
                    color: Color(0xFFC4C4C7),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            DefaultTextStyle(style: AppText.body, child: child),
          ],
        ),
      ),
    );
  }
}

class BigValue extends StatelessWidget {
  const BigValue(
    this.value, {
    super.key,
    this.unit,
    this.color,
    this.size = 30,
  });

  final String value;
  final String? unit;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              color: color ?? AppColors.label,
            ),
          ),
          if (unit != null)
            TextSpan(
              text: ' $unit',
              style: AppText.subhead.copyWith(fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.text, {super.key, this.action, this.onAction});

  final String text;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 26, bottom: 10, left: 2),
      child: Row(
        children: [
          Expanded(child: Text(text, style: AppText.title2)),
          if (action != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: onAction,
              child: Text(
                action!,
                style: AppText.body.copyWith(color: AppColors.blue),
              ),
            ),
        ],
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.blue,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: color,
        disabledColor: color.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        onPressed: loading ? null : onPressed,
        child: loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.headline.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class TintedButton extends StatelessWidget {
  const TintedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color = AppColors.blue,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: color, size: 19),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: AppText.headline.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class Callout extends StatelessWidget {
  const Callout({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
  });

  final Color color;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppText.subhead.copyWith(color: AppColors.label),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.tertiaryLabel),
          const SizedBox(height: 14),
          Text(title, style: AppText.title3, textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(message, style: AppText.subhead, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 22), action!],
        ],
      ),
    );
  }
}

class SimulationNote extends StatelessWidget {
  const SimulationNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.lock_shield_fill,
            size: 14,
            color: AppColors.gray,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Prototipe akademik · seluruh data adalah simulasi',
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

void showMessage(
  BuildContext context,
  String message, {
  bool error = false,
  IconData? icon,
}) {
  final color = error ? AppColors.red : AppColors.green;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        content: Row(
          children: [
            IconTile(
              icon ??
                  (error
                      ? CupertinoIcons.exclamationmark
                      : CupertinoIcons.checkmark_alt),
              color: icon != null ? AppColors.blue : color,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Ya',
  bool destructive = false,
}) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (ctx) => CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(message),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        CupertinoDialogAction(
          isDefaultAction: !destructive,
          isDestructiveAction: destructive,
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<DateTime?> pickDateTime(
  BuildContext context, {
  required DateTime initial,
  DateTime? minimum,
  DateTime? maximum,
  CupertinoDatePickerMode mode = CupertinoDatePickerMode.date,
  String title = 'Pilih Tanggal',
}) {
  var value = initial;
  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (ctx) => Container(
      height: 320,
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Row(
              children: [
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppText.headline,
                  ),
                ),
                CupertinoButton(
                  onPressed: () => Navigator.pop(ctx, value),
                  child: const Text(
                    'Selesai',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            Container(height: 0.5, color: AppColors.separator),
            Expanded(
              child: CupertinoDatePicker(
                mode: mode,
                initialDateTime: initial,
                minimumDate: minimum,
                maximumDate: maximum,
                use24hFormat: true,
                onDateTimeChanged: (d) => value = d,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<void> showFormSheet(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext) builder,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.groupedBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
    ),
    builder: builder,
  );
}

class SheetHeader extends StatelessWidget {
  const SheetHeader({
    super.key,
    required this.title,
    required this.onSave,
    this.saveLabel = 'Simpan',
  });

  final String title;
  final VoidCallback onSave;
  final String saveLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.headline,
            ),
          ),
          CupertinoButton(
            onPressed: onSave,
            child: Text(
              saveLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

String relativeDay(DateTime d, DateTime today) {
  if (Fmt.sameDay(d, today)) return 'Hari ini';
  if (Fmt.sameDay(d, today.add(const Duration(days: 1)))) return 'Besok';
  return Fmt.fullDate(d);
}
