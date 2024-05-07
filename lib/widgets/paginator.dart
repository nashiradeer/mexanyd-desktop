import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Parameters from paginator to fetch data.
class PaginatorFetchParameters {
  /// Offset, calculated from the current page and page size.
  final int offset;

  /// Current page number.
  final int currentPage;

  /// Total number of pages.
  final int totalPages;

  /// Number of items per page.
  final int pageSize;

  /// Creates a new [PaginatorFetchParameters].
  const PaginatorFetchParameters(
    this.offset,
    this.currentPage,
    this.totalPages,
    this.pageSize,
  );
}

/// Data returned by the prefetch function.
class PaginatorPrefetchData<T> {
  /// Header to be displayed, if any.
  final T? header;

  /// Total number of items.
  final int itemCount;

  /// Creates a new [PaginatorPrefetchData].
  const PaginatorPrefetchData(this.itemCount, {this.header});
}

/// Paginator widget.
class Paginator<T, H> extends StatefulWidget {
  /// Function to build the item widget.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Function to fetch data.
  final Future<List<T>> Function(PaginatorFetchParameters params) fetcher;

  /// Function to prefetch data to get the total number of items.
  final Future<PaginatorPrefetchData<H>> Function(BuildContext context)
      prefetch;

  /// Function to build the header widget.
  final Widget Function(BuildContext context, H? header)? headerBuilder;

  /// Number of items per page.
  final int pageSize;

  /// Creates a new [Paginator].
  const Paginator({
    super.key,
    required this.itemBuilder,
    required this.fetcher,
    required this.prefetch,
    this.pageSize = 50,
    this.headerBuilder,
  });

  @override
  State<Paginator<T, H>> createState() => _PaginatorState();
}

/// State of the [Paginator].
class _PaginatorState<T, H> extends State<Paginator<T, H>> {
  /// Current page number.
  int _currentPage = 0;

  /// Total number of pages.
  int _totalPages = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: () async {
        final prefetchData = await widget.prefetch(context);
        final totalPages = (prefetchData.itemCount / widget.pageSize).ceil();
        final data = await widget.fetcher(PaginatorFetchParameters(
          _currentPage * widget.pageSize,
          _currentPage,
          _totalPages,
          widget.pageSize,
        ));
        return _InternalPaginatorData(data, totalPages,
            header: prefetchData.header);
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data as _InternalPaginatorData<T, H>;

          if (data.data.isEmpty) {
            return _buildEmpty();
          }

          if (data.pageCount != _totalPages) {
            _currentPage = 0;
            _totalPages = data.pageCount;
          }

          return _buildList(
              data, widget.headerBuilder?.call(context, data.header));
        } else if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }

        return _buildLoading();
      },
    );
  }

  /// Builds the loading widget.
  Widget _buildLoading() {
    return const Expanded(
      child: Center(
        child: SizedBox.square(
          dimension: 80,
          child: CircularProgressIndicator(
            strokeWidth: 15,
            strokeCap: StrokeCap.round,
            strokeAlign: -1,
          ),
        ),
      ),
    );
  }

  /// Builds the error widget.
  Widget _buildError(String message) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 100, color: Colors.red),
          Text(
            AppLocalizations.of(context)!.error,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(message),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  /// Builds the widget when there is no data.
  Widget _buildEmpty() {
    return Expanded(
      child: Center(
        child: Text(
          AppLocalizations.of(context)!.noDataFound,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// Builds the list widget.
  Widget _buildList(_InternalPaginatorData data, Widget? header) {
    return Expanded(
      child: Column(
        children: [
          _buildPaginator(header),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.data.length,
              itemBuilder: (context, index) {
                return widget.itemBuilder(context, data.data[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the paginator widget.
  Widget _buildPaginator(Widget? header) {
    return Row(
      children: [
        if (header != null) header,
        const Spacer(),
        IconButton(
          onPressed: (_currentPage > 0) ? _prevPage : null,
          icon: const Icon(Icons.arrow_back_ios_rounded),
        ),
        Text("${_currentPage + 1}/$_totalPages"),
        IconButton(
          onPressed: (_currentPage < _totalPages - 1) ? _nextPage : null,
          icon: const Icon(Icons.arrow_forward_ios_rounded),
        ),
      ],
    );
  }

  /// Goes to the next page.
  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  /// Goes to the previous page.
  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }
}

/// Internal data used by the [Paginator].
class _InternalPaginatorData<T, H> {
  /// Data to be displayed.
  final List<T> data;

  /// Header to be displayed, if any.
  final H? header;

  /// Total number of pages.
  final int pageCount;

  /// Creates a new [_InternalPaginatorData].
  const _InternalPaginatorData(this.data, this.pageCount, {this.header});
}
