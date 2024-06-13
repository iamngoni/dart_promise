//
//  dart_promise
//  promise.dart
//
//  Created by Ngonidzashe Mangudya on 13/06/2024.
//  Copyright (c) 2024 Codecraft Solutions. All rights reserved.
//

import 'dart:async';

import 'types.dart';

class Promise<T> {
  Promise(Executor<T> executor) {
    final completer = Completer<T>();
    _future = completer.future;
    try {
      executor(completer.complete, completer.completeError);
    } catch (e) {
      completer.completeError(e);
    }
  }

  late Future<T> _future;

  Promise<TResult> then<TResult>(
    OnFulfilled<T, TResult> onFulfilled, {
    OnRejected<TResult>? onRejected,
  }) {
    return Promise<TResult>((resolve, reject) {
      _future.then(
        (value) => resolve(onFulfilled(value)),
        onError: (Object error) {
          if (onRejected != null) {
            try {
              return resolve(onRejected(error));
            } catch (e) {
              return reject(e);
            }
          } else {
            return reject(error);
          }
        },
      );
    });
  }

  FutureOr<T> catchError(OnRejected<T> onRejected) {
    return _future.catchError((Object error) async {
      try {
        return onRejected(error);
      } catch (e) {
        rethrow;
      }
    });
  }

  static Promise<void> resolve() {
    return Promise<void>((resolve, _) => resolve(null));
  }

  static Promise<void> reject(Object error) {
    return Promise<void>((_, reject) => reject(error));
  }

  static Promise<List<T>> all<T>(List<Promise<T>> promises) {
    return Promise<List<T>>((resolve, reject) {
      Future.wait(promises.map((p) => p._future))
          .then(resolve)
          .catchError(reject);
    });
  }

  static Promise<T> race<T>(List<Promise<T>> promises) {
    final completer = Completer<T>();

    for (final promise in promises) {
      promise._future.then(
        (value) {
          if (!completer.isCompleted) {
            completer.complete(value);
          }
        },
        onError: (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );
    }

    return Promise<T>((resolve, reject) {
      completer.future.then(
        resolve,
        onError: (Object error) => reject(error),
      );
    });
  }

  Future<T> toFuture() {
    return _future;
  }
}
