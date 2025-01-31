import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/src/common.dart';
import 'package:rxdart/rxdart.dart';

import 'locale_utils.dart';

class MonthSelector extends StatefulWidget {
  final ValueChanged<DateTime> onMonthSelected;
  final DateTime? openDate,
      selectedDate,
      firstDate,
      lastDate;
  final PublishSubject<UpDownPageLimit>
      upDownPageLimitPublishSubject;
  final PublishSubject<UpDownButtonEnableState>
      upDownButtonEnableStatePublishSubject;
  final Locale? locale;
  final Color? color;
  final Color? colorSelected;
  const MonthSelector({
    Key? key,
    required DateTime this.openDate,
    required DateTime this.selectedDate,
    required this.onMonthSelected,
    required this.upDownPageLimitPublishSubject,
    required this.upDownButtonEnableStatePublishSubject,
    this.firstDate,
    this.lastDate,
    this.locale, this.color, this.colorSelected,
  })  : assert(openDate != null),
        assert(selectedDate != null),
        assert(onMonthSelected != null),
        assert(upDownPageLimitPublishSubject !=
            null),
        assert(
            upDownButtonEnableStatePublishSubject !=
                null),
        super(key: key);
  @override
  State<StatefulWidget> createState() =>
      MonthSelectorState();
}

class MonthSelectorState
    extends State<MonthSelector> {
  PageController? _pageController;

  @override
  Widget build(BuildContext context) =>
      PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        physics:
            const AlwaysScrollableScrollPhysics(),
        onPageChanged: _onPageChange,
        itemCount: _getPageCount(),
        itemBuilder: _yearGridBuilder,
      );

  Widget _yearGridBuilder(
          final BuildContext context,
          final int page) =>
      GridView.count(
        physics:
            const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(8.0),
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: List<Widget>.generate(
          12,
          (final int index) => _getMonthButton(
              DateTime(
                  widget.firstDate != null
                      ? widget.firstDate!.year +
                          page
                      : page,
                  index + 1),
              getLocale(context,
                  selectedLocale: widget.locale)),
        ).toList(growable: false),
      );

  Widget _getMonthButton(
      final DateTime date, final String locale) {
    final bool isEnabled = _isEnabled(date);
    return ElevatedButton(
        onPressed: isEnabled
            ? () => widget.onMonthSelected(
                DateTime(date.year, date.month))
            : null,
        style: ElevatedButton.styleFrom(
            maximumSize: Size(50, 50),
            fixedSize: Size(50, 50),
            primary: date.month ==
                        widget.selectedDate!
                            .month &&
                    date.year ==
                        widget.selectedDate!.year
                ? widget.colorSelected ?? Color(0xffC7870D)
                : widget.color ?? Color(0xffECA00F),
            minimumSize: Size(50, 50)),
        // child: Text(
        //   DateFormat.MMM(locale).format(date),
        //   style: TextStyle(color: Colors.white),
        // ),
        child: Text(
            DateFormat.MMM(locale).format(date),
            style: GoogleFonts.roboto(
                textStyle: TextStyle(
                    color: Colors.white))));
  }

  void _onPageChange(final int page) {
    widget.upDownPageLimitPublishSubject.add(
      new UpDownPageLimit(
        widget.firstDate != null
            ? widget.firstDate!.year + page
            : page,
        0,
      ),
    );
    widget.upDownButtonEnableStatePublishSubject
        .add(
      new UpDownButtonEnableState(
          page > 0, page < _getPageCount() - 1),
    );
  }

  int _getPageCount() {
    if (widget.firstDate != null &&
        widget.lastDate != null) {
      return widget.lastDate!.year -
          widget.firstDate!.year +
          1;
    } else if (widget.firstDate != null &&
        widget.lastDate == null) {
      return 9999 - widget.firstDate!.year;
    } else if (widget.firstDate == null &&
        widget.lastDate != null) {
      return widget.lastDate!.year + 1;
    } else
      return 9999;
  }

  @override
  void initState() {
    _pageController = new PageController(
        initialPage: widget.firstDate == null
            ? widget.openDate!.year
            : widget.openDate!.year -
                widget.firstDate!.year);
    super.initState();
    new Future.delayed(Duration.zero, () {
      widget.upDownPageLimitPublishSubject.add(
        new UpDownPageLimit(
          widget.firstDate == null
              ? _pageController!.page!.toInt()
              : widget.firstDate!.year +
                  _pageController!.page!.toInt(),
          0,
        ),
      );
      widget.upDownButtonEnableStatePublishSubject
          .add(
        new UpDownButtonEnableState(
          _pageController!.page!.toInt() > 0,
          _pageController!.page!.toInt() <
              _getPageCount() - 1,
        ),
      );
    });
  }

  @override
  void dispose() {
    _pageController!.dispose();
    super.dispose();
  }

  bool _isEnabled(final DateTime date) {
    if (widget.firstDate == null &&
        widget.lastDate == null)
      return true;
    else if (widget.firstDate != null &&
        widget.lastDate != null &&
        widget.firstDate!.compareTo(date) <= 0 &&
        widget.lastDate!.compareTo(date) >= 0)
      return true;
    else if (widget.firstDate != null &&
        widget.lastDate == null &&
        widget.firstDate!.compareTo(date) <= 0)
      return true;
    else if (widget.firstDate == null &&
        widget.lastDate != null &&
        widget.lastDate!.compareTo(date) >= 0)
      return true;
    else
      return false;
  }

  void goDown() {
    _pageController!.animateToPage(
      _pageController!.page!.toInt() + 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void goUp() {
    _pageController!.animateToPage(
      _pageController!.page!.toInt() - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}
