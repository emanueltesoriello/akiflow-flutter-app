import 'package:flutter/material.dart';
import 'package:mobile/src/availability/ui/widgets/imported_from_material/chevron_icon.dart';

const double _kPanelHeaderCollapsedHeight = kMinInteractiveDimension;
const EdgeInsets _kPanelHeaderExpandedDefaultPadding = EdgeInsets.symmetric(
  vertical: 64.0 - _kPanelHeaderCollapsedHeight,
);

class _SaltedKey<S, V> extends LocalKey {
  const _SaltedKey(this.salt, this.value);

  final S salt;
  final V value;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _SaltedKey<S, V> && other.salt == salt && other.value == value;
  }

  @override
  int get hashCode => Object.hash(runtimeType, salt, value);

  @override
  String toString() {
    final String saltString = S == String ? "<'$salt'>" : '<$salt>';
    final String valueString = V == String ? "<'$value'>" : '<$value>';
    return '[$saltString $valueString]';
  }
}

/// Signature for the callback that's called when an [ExpandablePanel] is
/// expanded or collapsed.
///
/// The position of the panel within an [ExpandablePanelList] is given by
/// [panelIndex].
typedef ExpandablePanelCallback = void Function(int panelIndex, bool isExpanded);

/// Signature for the callback that's called when the header of the
/// [ExpandablePanel] needs to rebuild.
typedef ExpandablePanelHeaderBuilder = Widget Function(BuildContext context, bool isExpanded);

/// A material expansion panel. It has a header and a body and can be either
/// expanded or collapsed. The body of the panel is only visible when it is
/// expanded.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=2aJZzRMziJc}
///
/// Expansion panels are only intended to be used as children for
/// [ExpandablePanelList].
///
/// See [ExpandablePanelList] for a sample implementation.
///
/// See also:
///
///  * [ExpandablePanelList]
///  * <https://material.io/design/components/lists.html#types>
class ExpandablePanel {
  /// Creates an expansion panel to be used as a child for [ExpandablePanelList].
  /// See [ExpandablePanelList] for an example on how to use this widget.
  ///
  /// The [headerBuilder], [body], and [isExpanded] arguments must not be null.
  ExpandablePanel({
    required this.headerBuilder,
    required this.body,
    this.isExpanded = false,
    this.canTapOnHeader = false,
    this.isHeaderVisible = true,
    this.backgroundColor,
  });

  /// The widget builder that builds the expansion panels' header.
  final ExpandablePanelHeaderBuilder headerBuilder;

  /// The body of the expansion panel that's displayed below the header.
  ///
  /// This widget is visible only when the panel is expanded.
  final Widget body;

  final bool isHeaderVisible;

  /// Whether the panel is expanded.
  ///
  /// Defaults to false.
  final bool isExpanded;

  /// Whether tapping on the panel's header will expand/collapse it.
  ///
  /// Defaults to false.
  final bool canTapOnHeader;

  /// Defines the background color of the panel.
  ///
  /// Defaults to [ThemeData.cardColor].
  final Color? backgroundColor;
}

/// An expansion panel that allows for radio-like functionality.
/// This means that at any given time, at most, one [ExpandablePanelRadio]
/// can remain expanded.
///
/// A unique identifier [value] must be assigned to each panel.
/// This identifier allows the [ExpandablePanelList] to determine
/// which [ExpandablePanelRadio] instance should be expanded.
///
/// See [ExpandablePanelList.radio] for a sample implementation.
class ExpandablePanelRadio extends ExpandablePanel {
  /// An expansion panel that allows for radio functionality.
  ///
  /// A unique [value] must be passed into the constructor. The
  /// [headerBuilder], [body], [value] must not be null.
  ExpandablePanelRadio({
    required this.value,
    required super.headerBuilder,
    required super.body,
    super.canTapOnHeader,
    super.backgroundColor,
  });

  /// The value that uniquely identifies a radio panel so that the currently
  /// selected radio panel can be identified.
  final Object value;
}

/// A material expansion panel list that lays out its children and animates
/// expansions.
///
/// Note that [expansionCallback] behaves differently for [ExpandablePanelList]
/// and [ExpandablePanelList.radio].
///
/// {@tool dartpad}
/// Here is a simple example of how to implement ExpandablePanelList.
///
/// ** See code in examples/api/lib/material/expansion_panel/expansion_panel_list.0.dart **
/// {@end-tool}
///
/// See also:
///
///  * [ExpandablePanel]
///  * [ExpandablePanelList.radio]
///  * <https://material.io/design/components/lists.html#types>
class ExpandablePanelList extends StatefulWidget {
  /// Creates an expansion panel list widget. The [expansionCallback] is
  /// triggered when an expansion panel expand/collapse button is pushed.
  ///
  /// The [children] and [animationDuration] arguments must not be null.
  const ExpandablePanelList({
    super.key,
    this.children = const <ExpandablePanel>[],
    this.expansionCallback,
    this.isHeaderVisible = true,
    this.animationDuration = const Duration(milliseconds: 10),
    this.expandedHeaderPadding = const EdgeInsets.all(0.0),
    this.dividerColor,
    this.elevation = 2,
  })  : _allowOnlyOnePanelOpen = false,
        initialOpenPanelValue = null;

  /// Creates a radio expansion panel list widget.
  ///
  /// This widget allows for at most one panel in the list to be open.
  /// The expansion panel callback is triggered when an expansion panel
  /// expand/collapse button is pushed. The [children] and [animationDuration]
  /// arguments must not be null. The [children] objects must be instances
  /// of [ExpandablePanelRadio].
  ///
  /// {@tool dartpad}
  /// Here is a simple example of how to implement ExpandablePanelList.radio.
  ///
  /// ** See code in examples/api/lib/material/expansion_panel/expansion_panel_list.expansion_panel_list_radio.0.dart **
  /// {@end-tool}
  const ExpandablePanelList.radio({
    super.key,
    this.children = const <ExpandablePanelRadio>[],
    this.expansionCallback,
    this.animationDuration = kThemeAnimationDuration,
    this.initialOpenPanelValue,
    this.expandedHeaderPadding = _kPanelHeaderExpandedDefaultPadding,
    this.dividerColor,
    this.elevation = 2,
    required this.isHeaderVisible,
  }) : _allowOnlyOnePanelOpen = true;

  /// The children of the expansion panel list. They are laid out in a similar
  /// fashion to [ListBody].
  final List<ExpandablePanel> children;

  /// The callback that gets called whenever one of the expand/collapse buttons
  /// is pressed. The arguments passed to the callback are the index of the
  /// pressed panel and whether the panel is currently expanded or not.
  ///
  /// If ExpandablePanelList.radio is used, the callback may be called a
  /// second time if a different panel was previously open. The arguments
  /// passed to the second callback are the index of the panel that will close
  /// and false, marking that it will be closed.
  ///
  /// For ExpandablePanelList, the callback needs to setState when it's notified
  /// about the closing/opening panel. On the other hand, the callback for
  /// ExpandablePanelList.radio is simply meant to inform the parent widget of
  /// changes, as the radio panels' open/close states are managed internally.
  ///
  /// This callback is useful in order to keep track of the expanded/collapsed
  /// panels in a parent widget that may need to react to these changes.
  final ExpandablePanelCallback? expansionCallback;

  /// The duration of the expansion animation.
  final Duration animationDuration;

  // Whether multiple panels can be open simultaneously
  final bool _allowOnlyOnePanelOpen;

  final bool isHeaderVisible;

  /// The value of the panel that initially begins open. (This value is
  /// only used when initializing with the [ExpandablePanelList.radio]
  /// constructor.)
  final Object? initialOpenPanelValue;

  /// The padding that surrounds the panel header when expanded.
  ///
  /// By default, 16px of space is added to the header vertically (above and below)
  /// during expansion.
  final EdgeInsets expandedHeaderPadding;

  /// Defines color for the divider when [ExpandablePanel.isExpanded] is false.
  ///
  /// If `dividerColor` is null, then [DividerThemeData.color] is used. If that
  /// is null, then [ThemeData.dividerColor] is used.
  final Color? dividerColor;

  /// Defines elevation for the [ExpandablePanel] while it's expanded.
  ///
  /// By default, the value of elevation is 2.
  final double elevation;

  @override
  State<StatefulWidget> createState() => _ExpandablePanelListState();
}

class _ExpandablePanelListState extends State<ExpandablePanelList> {
  ExpandablePanelRadio? _currentOpenPanel;

  @override
  void initState() {
    super.initState();
    if (widget._allowOnlyOnePanelOpen) {
      assert(_allIdentifiersUnique(), 'All ExpandablePanelRadio identifier values must be unique.');
      if (widget.initialOpenPanelValue != null) {
        _currentOpenPanel =
            searchPanelByValue(widget.children.cast<ExpandablePanelRadio>(), widget.initialOpenPanelValue);
      }
    }
  }

  @override
  void didUpdateWidget(ExpandablePanelList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._allowOnlyOnePanelOpen) {
      assert(_allIdentifiersUnique(), 'All ExpandablePanelRadio identifier values must be unique.');
      // If the previous widget was non-radio ExpandablePanelList, initialize the
      // open panel to widget.initialOpenPanelValue
      if (!oldWidget._allowOnlyOnePanelOpen) {
        _currentOpenPanel =
            searchPanelByValue(widget.children.cast<ExpandablePanelRadio>(), widget.initialOpenPanelValue);
      }
    } else {
      _currentOpenPanel = null;
    }
  }

  bool _allIdentifiersUnique() {
    final Map<Object, bool> identifierMap = <Object, bool>{};
    for (final ExpandablePanelRadio child in widget.children.cast<ExpandablePanelRadio>()) {
      identifierMap[child.value] = true;
    }
    return identifierMap.length == widget.children.length;
  }

  bool _isChildExpanded(int index) {
    if (widget._allowOnlyOnePanelOpen) {
      final ExpandablePanelRadio radioWidget = widget.children[index] as ExpandablePanelRadio;
      return _currentOpenPanel?.value == radioWidget.value;
    }
    return widget.children[index].isExpanded;
  }

  void _handlePressed(bool isExpanded, int index) {
    widget.expansionCallback?.call(index, isExpanded);

    if (widget._allowOnlyOnePanelOpen) {
      final ExpandablePanelRadio pressedChild = widget.children[index] as ExpandablePanelRadio;

      // If another ExpandablePanelRadio was already open, apply its
      // expansionCallback (if any) to false, because it's closing.
      for (int childIndex = 0; childIndex < widget.children.length; childIndex += 1) {
        final ExpandablePanelRadio child = widget.children[childIndex] as ExpandablePanelRadio;
        if (widget.expansionCallback != null && childIndex != index && child.value == _currentOpenPanel?.value) {
          widget.expansionCallback!(childIndex, false);
        }
      }

      setState(() {
        _currentOpenPanel = isExpanded ? null : pressedChild;
      });
    }
  }

  ExpandablePanelRadio? searchPanelByValue(List<ExpandablePanelRadio> panels, Object? value) {
    for (final ExpandablePanelRadio panel in panels) {
      if (panel.value == value) {
        return panel;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    assert(
      kElevationToShadow.containsKey(widget.elevation),
      'Invalid value for elevation. See the kElevationToShadow constant for'
      ' possible elevation values.',
    );

    final List<MergeableMaterialItem> items = <MergeableMaterialItem>[];

    for (int index = 0; index < widget.children.length; index += 1) {
      if (_isChildExpanded(index) && index != 0 && !_isChildExpanded(index - 1)) {
        items.add(MaterialGap(key: _SaltedKey<BuildContext, int>(context, index * 2 - 1)));
      }

      final ExpandablePanel child = widget.children[index];
      final Widget headerWidget = child.headerBuilder(
        context,
        _isChildExpanded(index),
      );

      Widget expandIconContainer = Container(
        margin: const EdgeInsetsDirectional.only(end: 0.0),
        child: ChevronIcon(
          isExpanded: _isChildExpanded(index),
          padding: const EdgeInsets.all(0.0),
          onPressed: !child.canTapOnHeader ? (bool isExpanded) => _handlePressed(isExpanded, index) : null,
        ),
      );
      if (!child.canTapOnHeader) {
        final MaterialLocalizations localizations = MaterialLocalizations.of(context);
        expandIconContainer = Semantics(
          label: _isChildExpanded(index) ? localizations.expandedIconTapHint : localizations.collapsedIconTapHint,
          container: true,
          child: expandIconContainer,
        );
      }
      Widget header = Row(
        children: <Widget>[
          Expanded(
            child: Container(
              // AnimatedContainer(
              //  duration: widget.animationDuration,
              //  curve: Curves.fastOutSlowIn,
              margin: _isChildExpanded(index) ? widget.expandedHeaderPadding : EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: _kPanelHeaderCollapsedHeight),
                child: headerWidget,
              ),
            ),
          ),
          expandIconContainer,
        ],
      );
      if (child.canTapOnHeader) {
        header = MergeSemantics(
          child: InkWell(
            onTap: () => _handlePressed(_isChildExpanded(index), index),
            child: header,
          ),
        );
      }
      items.add(
        MaterialSlice(
          key: _SaltedKey<BuildContext, int>(context, index * 2),
          color: child.backgroundColor,
          child: Visibility(
            visible: child.isHeaderVisible,
            child: Column(
              children: <Widget>[
                header,
                AnimatedCrossFade(
                  firstChild: Container(height: 0.0),
                  secondChild: child.body,
                  //  firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
                  // secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
                  sizeCurve: Curves.fastOutSlowIn,
                  crossFadeState: _isChildExpanded(index) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  duration: widget.animationDuration,
                ),
              ],
            ),
          ),
        ),
      );

      if (_isChildExpanded(index) && index != widget.children.length - 1) {
        items.add(MaterialGap(key: _SaltedKey<BuildContext, int>(context, index * 2 + 1)));
      }
    }

    return MergeableMaterial(
      hasDividers: true,
      dividerColor: widget.dividerColor,
      elevation: widget.elevation,
      children: items,
    );
  }
}
