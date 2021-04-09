// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:collection';
import 'package:meta/meta.dart';
import 'package:quiver/core.dart';
import 'package:quiver/collection.dart';

@immutable
class Interval<T extends Comparable<T>, U extends Object> extends Comparable<Interval<T, U>> {
  Interval(this._start, this._end, [this._payload]);

  /// Creates a copy of the [other] interval.
  Interval.copy(Interval<T, U> other)
      : _start = other._start,
        _end = other._end,
        _payload = other._payload;

  U? mergePayload(Interval<T, U> other) {
    return _payload;
  }

  U? get payload => _payload;
  final U? _payload;

  /// Returns the start point of this interval.
  T get start => _start;

  /// Returns the end point of this interval.
  T get end => _end;

  /// Returns `true` if this interval contains the [other] interval.
  bool contains(Interval<T, U> other) {
    return other.start.compareTo(start) >= 0 && other.end.compareTo(end) <= 0;
  }

  /// Returns `true` if this interval intersects with the [other] interval.
  bool intersects(Interval<T, U> other) {
    return other.start.compareTo(end) <= 0 && other.end.compareTo(start) >= 0;
  }

  /// Returns the union of this interval and the [other] interval.
  ///
  /// In other words, the returned interval contains the points that are in
  /// either interval.
  ///
  ///     final a = Interval(0, 3);
  ///     final b = Interval(2, 5);
  ///     print(a.union(b)); // [[0, 5]]
  ///
  /// Notice that `a.union(b) = b.union(a)`.
  ///
  /// The returned interval is the entire interval from the smaller start to the
  /// larger end, including any gap in between.
  ///
  ///     final a = Interval(0, 2);
  ///     final b = Interval(3, 5);
  ///     print(b.union(a)); // [0, 5]
  ///
  Interval<T, U> union(Interval<T, U> other) =>
      Interval<T, U>(_min(start, other.start), _max(end, other.end), mergePayload(other));

  /// Returns the intersection between this interval and the [other] interval,
  /// or `null` if the intervals do not intersect.
  ///
  /// In other words, the returned interval contains the points that are also
  /// in the [other] interval.
  ///
  ///     final a = Interval(0, 3);
  ///     final b = Interval(2, 5);
  ///     print(a.intersection(b)); // [[2, 3]]
  ///
  /// Notice that `a.intersection(b) = b.intersection(a)`.
  ///
  /// The returned interval may be `null` if the intervals do not intersect.
  ///
  ///     final a = Interval(0, 2);
  ///     final b = Interval(3, 5);
  ///     print(b.intersection(a)); // null
  ///
  Interval<T, U>? intersection(Interval<T, U> other) {
    if (!intersects(other)) {
      return null;
    }
    return Interval<T, U>(_max(start, other.start), _min(end, other.end), mergePayload(other));
  }

  /// Returns the difference between this interval and the [other] interval,
  /// or `null` if the [other] interval contains this interval.
  ///
  /// In other words, the returned iterable contains the interval(s) that are
  /// not in the [other] interval.
  ///
  ///     final a = Interval(0, 3);
  ///     final b = Interval(2, 5);
  ///     print(a.difference(b)); // [[0, 2]]
  ///     print(b.difference(a)); // [[3, 5]]
  ///
  /// Notice that `a.difference(b) != b.difference(a)`.
  ///
  /// The returned iterable may contain multiple intervals if removing the
  /// [other] interval splits the remaining interval, or `null` if there is no
  /// interval left after removing the [other] interval.
  ///
  ///     final a = Interval(1, 5);
  ///     final b = Interval(2, 4);
  ///     print(a.difference(b)); // [[1, 2], [4, 5]]
  ///     print(b.difference(a)); // null
  ///
  Iterable<Interval<T, U>>? difference(Interval<T, U> other) {
    if (other.contains(this)) {
      return null;
    }
    if (!other.intersects(this)) {
      return <Interval<T, U>>[this];
    }

    if (start.compareTo(other.start) < 0 && end.compareTo(other.end) <= 0) {
      return <Interval<T, U>>[Interval<T, U>(start, other.start, mergePayload(other))];
    }
    if (start.compareTo(other.start) >= 0 && end.compareTo(other.end) > 0) {
      return <Interval<T, U>>[Interval<T, U>(other.end, end, mergePayload(other))];
    }
    return <Interval<T, U>>[
      Interval<T, U>(start, other.start, mergePayload(other)),
      Interval<T, U>(other.end, end, mergePayload(other)),
    ];
  }

  /// Compares this interval to the [other] interval.
  ///
  /// Two intervals are considered _equal_ when their [start] and [end] points
  /// are equal. Otherwise, the one that starts first comes first, or if the
  /// start points are equal, the one that ends first.
  ///
  /// Similarly to [Comparator], returns:
  /// - a negative integer if this interval is _less than_ the [other] interval,
  /// - a positive integer if this interval is _greater than_ the [other]
  ///   interval,
  /// - zero if this interval is _equal to_ the [other] interval.
  @override
  int compareTo(Interval<T, U> other) {
    return start == other.start ? _cmp(end, other.end) : _cmp(start, other.start);
  }

  /// Returns `true` if this interval start or ends before the [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator <(Interval<T, U> other) => compareTo(other) < 0;

  /// Returns `true` if this interval starts or ends before or same as the
  /// [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator <=(Interval<T, U> other) => compareTo(other) <= 0;

  /// Returns `true` if this interval starts or ends after the [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator >(Interval<T, U> other) => compareTo(other) > 0;

  /// Returns `true` if this interval starts or ends after or same as the
  /// [other] interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  bool operator >=(Interval<T, U> other) => compareTo(other) >= 0;

  /// Returns `true` if this interval starts and ends same as the [other]
  /// interval.
  ///
  /// See [compareTo] for detailed interval comparison rules.
  @override
  bool operator ==(Object other) {
    return other is Interval<T, U> && start == other.start && end == other.end;
  }

  /// Returns the hash code for this interval.
  @override
  int get hashCode => hash2(start, end);

  /// Returns a string representation of this interval.
  @override
  String toString() => '[$start, $end]';

  static int _cmp<T extends Comparable<T>>(T a, T b) => a.compareTo(b);
  static T _min<T extends Comparable<T>>(T a, T b) => _cmp(a, b) < 0 ? a : b;
  static T _max<T extends Comparable<T>>(T a, T b) => _cmp(a, b) > 0 ? a : b;

  final T _start;
  final T _end;
}

/// A non-overlapping collection of intervals organized into a tree.
///
/// IntervalTree has support for adding and removing intervals, or entire
/// iterable collections of intervals, such as other interval trees.
///
///     final IntervalTree tree = IntervalTree.from([[1, 3], [5, 8], [10, 15]]);
///     print(tree); // IntervalTree([1, 3], [5, 8], [10, 15])
///
///     tree.add([2, 6]);
///     print(tree); // IntervalTree([1, 8], [10, 15])
///
///     tree.remove([12, 16]);
///     print(tree); // IntervalTree([1, 8], [10, 12])
///
/// As illustrated  by the above example, IntervalTree automatically joins and
/// splits appropriate intervals at insertions and removals, respectively,
/// whilst maintaining a collection of non-overlapping intervals.
///
/// IntervalTree can also calculate unions, intersections, and differences
/// between collections of intervals:
///
///     final IntervalTree tree = IntervalTree.from([[1, 8], [10, 12]]);
///     final IntervalTree other = IntervalTree.from([[0, 2], [5, 7]]);
///
///     print(tree.union(other)); // IntervalTree([0, 8], [10, 12])
///     print(tree.intersection(other)); // IntervalTree([1, 2], [5, 7])
///     print(tree.difference(other)); // IntervalTree([2, 5], [7, 8], [10, 12])
///
/// IntervalTree is an [Iterable] collection offering all standard iterable
/// operations, such as easily iterating the entire tree, or accessing the first
/// and last intervals.
///
///     for (final interval in tree) {
///       print(interval); // [1, 8] \n [10, 12]
///     }
///
///     print(tree.first); // [1, 8]
///     print(tree.last); // [10, 12]
///
/// Notice that all methods that take interval arguments accept either
/// [Interval] objects or literal lists with two items. The latter is a natural
/// syntax for specifying intervals:
///
///     tree.add([0, 5]); // vs. tree.add(Interval(0, 5));
///
/// Notice that the Interval class name unfortunately clashes with the Interval
/// class from the Flutter animation library. However, there are two ways around
/// this problem. Either use the syntax with list literals, or import either
/// library with a name prefix, for example:
///
///     import 'package:interval_tree/interval_tree.dart' as ivt;
///
///     final interval = ivt.Interval(1, 2);
///
class IntervalTree<T extends Comparable<T>, U extends Object> with IterableMixin<Interval<T, U>> {
  /// Creates a tree, optionally with an [interval].
  IntervalTree([Interval<T, U>? interval]) {
    if (interval != null) {
      add(interval);
    }
  }

  /// Creates a tree from given iterable of [intervals].
  factory IntervalTree.from(Iterable<Interval<T, U>> intervals) {
    final IntervalTree<T, U> tree = IntervalTree<T, U>();
    intervals.forEach(tree.add);
    return tree;
  }

  /// Creates a tree from [intervals].
  factory IntervalTree.of(Iterable<Interval<T, U>> intervals) =>
      IntervalTree<T, U>()..addAll(intervals);

  /// Adds an [interval] into this tree.
  void add(dynamic interval) {
    Interval<T, U> iv = _asInterval(interval);
    if (iv == null) {
      return;
    }

    bool joined = false;
    BidirectionalIterator<Interval<T, U>> it = _tree.fromIterator(iv);
    while (it.movePrevious()) {
      final Interval<T, U>? union = _tryJoin(it.current, iv);
      if (union == null) {
        break;
      }
      it = _tree.fromIterator(iv = union, inclusive: false);
      joined = true;
    }

    it = _tree.fromIterator(iv, inclusive: false);
    while (it.moveNext()) {
      final Interval<T, U>? union = _tryJoin(it.current, iv);
      if (union == null) {
        break;
      }
      it = _tree.fromIterator(iv = union, inclusive: false);
      joined = true;
    }

    if (!joined) {
      _tree.add(iv);
    }
  }

  /// Adds all [intervals] into this tree.
  void addAll(Iterable<Interval<T, U>> intervals) {
    if (intervals == null) {
      return;
    }
    intervals.forEach(add);
  }

  /// Removes an [interval] from this tree.
  void remove(dynamic interval) {
    final Interval<T, U> iv = _asInterval(interval);
    if (iv == null) {
      return;
    }

    BidirectionalIterator<Interval<T, U>> it = _tree.fromIterator(iv);
    while (it.movePrevious()) {
      final Interval<T, U> current = it.current;
      if (!_trySplit(it.current, iv)) {
        break;
      }
      it = _tree.fromIterator(current, inclusive: false);
    }

    it = _tree.fromIterator(iv, inclusive: false);
    while (it.moveNext()) {
      final Interval<T, U> current = it.current;
      if (!_trySplit(it.current, iv)) {
        break;
      }
      it = _tree.fromIterator(current, inclusive: false);
    }
  }

  /// Removes all [intervals] from this tree.
  void removeAll(Iterable<Interval<T, U>> intervals) {
    if (intervals == null) {
      return;
    }
    intervals.forEach(remove);
  }

  /// Clears this tree.
  void clear() {
    _tree.clear();
  }

  // Returns the union of this tree and the [other] tree.
  IntervalTree<T, U> union(IntervalTree<T, U> other) => IntervalTree<T, U>.of(this)..addAll(other);

  // Returns the difference between this tree and the [other] tree.
  IntervalTree<T, U> difference(IntervalTree<T, U> other) =>
      IntervalTree<T, U>.of(this)..removeAll(other);

  // Returns the intersection of this tree and the [other] tree.
  IntervalTree<T, U> intersection(IntervalTree<T, U> other) {
    final IntervalTree<T, U> result = IntervalTree<T, U>();
    if (isEmpty || other.isEmpty) {
      return result;
    }
    for (final Interval<T, U> iv in other) {
      BidirectionalIterator<Interval<T, U>> it = _tree.fromIterator(iv);
      while (it.movePrevious() && iv.intersects(it.current)) {
        result.add(iv.intersection(it.current));
      }
      it = _tree.fromIterator(iv, inclusive: false);
      while (it.moveNext() && iv.intersects(it.current)) {
        result.add(iv.intersection(it.current));
      }
    }
    return result;
  }

  @override
  bool contains(dynamic element) {
    final Interval<T, U> iv = _asInterval(element);
    if (iv == null) {
      return false;
    }

    BidirectionalIterator<Interval<T, U>> it = _tree.fromIterator(iv);
    while (it.movePrevious() && iv.intersects(it.current)) {
      if (it.current.contains(iv)) {
        return true;
      }
    }
    it = _tree.fromIterator(iv, inclusive: false);
    while (it.moveNext() && it.current.intersects(iv)) {
      if (it.current.contains(iv)) {
        return true;
      }
    }
    return false;
  }

  /// Returns the number of intervals in this tree.
  @override
  int get length => _tree.length;

  /// Returns `true` if there are no intervals in this tree.
  @override
  bool get isEmpty => _tree.isEmpty;

  /// Returns `true` if there is at least one interval in this tree.
  @override
  bool get isNotEmpty => _tree.isNotEmpty;

  /// Returns the first interval in tree, or `null` if this tree is empty.
  @override
  Interval<T, U> get first => _tree.first;

  /// Returns the first interval in tree, or `null` if this tree is empty.
  @override
  Interval<T, U> get last => _tree.last;

  /// Checks that this tree has only one interval, and returns that interval.
  @override
  Interval<T, U> get single => _tree.single;

  /// Returns a bidirectional iterator that allows iterating the intervals.
  @override
  BidirectionalIterator<Interval<T, U>> get iterator => _tree.iterator;

  /// Returns a string representation of the tree.
  @override
  String toString() => 'IntervalTree' + super.toString();

  Interval<T, U> _asInterval(dynamic interval) {
    if (interval is Iterable<T>) {
      if (interval.length != 2 || interval.first is Iterable) {
        throw ArgumentError('$interval is not an interval');
      }
      return Interval<T, U>(interval.first, interval.last);
    }
    return interval as Interval<T, U>;
  }

  Interval<T, U>? _tryJoin(Interval<T, U> a, Interval<T, U> b) {
    if (a == null || b == null) {
      return null;
    }
    if (a.contains(b)) {
      return a;
    }
    if (!a.intersects(b)) {
      return null;
    }
    final Interval<T, U> union = a.union(b);
    _tree.remove(a);
    _tree.remove(b);
    _tree.add(union);
    return union;
  }

  bool _trySplit(Interval<T, U> a, Interval<T, U> b) {
    if (a == null || b == null) {
      return false;
    }
    if (!a.intersects(b)) {
      return false;
    }
    _tree.remove(a);
    _tree.addAll(<Interval<T, U>>[...?a.difference(b)]);
    return true;
  }

  final AvlTreeSet<Interval<T, U>> _tree =
      AvlTreeSet<Interval<T, U>>(comparator: Comparable.compare);
}
