// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:interval_tree/interval_tree.dart';

/// An interval between two values, `start` and `end`, with an associated payload.
@immutable
class PayloadInterval<T extends Comparable<T>, U extends Object> extends Interval {
  PayloadInterval(T start, T end, [this._payload]) : super(start, end);

  /// Creates a copy of the [other] interval.
  PayloadInterval.copy(PayloadInterval<T, U> other)
      : _payload = other._payload,
        super(other.start, other.end);

  PayloadInterval<T, U> copyWith(covariant T? start, covariant T? end, covariant U? payload) {
    return PayloadInterval<T, U>(start ?? this.start, end ?? this.end, payload ?? this.payload);
  }

  U? mergePayload(PayloadInterval<T, U> other) {
    return _payload;
  }

  U? get payload => _payload;
  final U? _payload;

  @override
  PayloadInterval<T, U> union(Interval other) =>
      copyWith(_min(start, other.start as T), _max(end, other.end as T), mergePayload(other as PayloadInterval<T, U>));

  @override
  PayloadInterval<T, U>? intersection(Interval other) {
    if (!intersects(other)) {
      return null;
    }
    return copyWith(_max(start, other.start as T), _min(end, other.end as T), mergePayload(other as PayloadInterval<T, U>));
  }

  @override
  Iterable<PayloadInterval<T, U>>? difference(Interval other) {
    if (other.contains(this)) {
      return null;
    }
    if (!other.intersects(this)) {
      return <PayloadInterval<T, U>>[this];
    }

    if (other is PayloadInterval<T, U>) {
      if (start.compareTo(other.start) < 0 && end.compareTo(other.end) <= 0) {
        return <PayloadInterval<T, U>>[
          copyWith(start, other.start, mergePayload(other))
        ];
      }
      if (start.compareTo(other.start) >= 0 && end.compareTo(other.end) > 0) {
        return <PayloadInterval<T, U>>[copyWith(other.end, end, mergePayload(other))];
      }
      return <PayloadInterval<T, U>>[
        copyWith(start, other.start, mergePayload(other)),
        copyWith(other.end, end, mergePayload(other)),
      ];
    } else {
      throw Exception('Unexpected interval type ${other.runtimeType}');
    }
  }

  @override
  T get start => super.start as T;

  @override
  T get end => super.end as T;

  /// Returns a string representation of this interval.
  @override
  String toString() => '[$start, $end]';

  static int _cmp<T extends Comparable<T>>(T a, T b) => a.compareTo(b);
  static T _min<T extends Comparable<T>>(T a, T b) => _cmp(a, b) < 0 ? a : b;
  static T _max<T extends Comparable<T>>(T a, T b) => _cmp(a, b) > 0 ? a : b;
}

