//
//  dart_promise
//  promise.dart
//
//  Created by Ngonidzashe Mangudya on 13/06/2024.
//  Copyright (c) 2024 Codecraft Solutions. All rights reserved.
//

import 'dart:async';

import 'types.dart';

/// A Promise class that mimics JavaScript-like promise functionality in Dart.
/// This class provides methods for handling asynchronous operations,
/// chaining them together, and handling errors in a controlled way.
class Promise<T> {
  /// Constructor for creating a new Promise.
  /// The executor function immediately executes with two parameters:
  /// `resolve` to settle the promise successfully, and `reject` to settle it
  /// with an error. If an exception occurs during execution, the promise is
  /// rejected with that exception.
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

  /// Attaches callbacks for the resolution and/or rejection of the Promise.
  /// [onFulfilled] is called if the Promise is resolved.
  /// [onRejected] is called if the Promise is rejected.
  /// Returns a new Promise resolving to the return value of the callback executed.
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

  /// Attaches a catch block that handles if the Promise is rejected.
  /// [onRejected] is a function that handles the error.
  /// Returns a `FutureOr<T>` allowing for continued chaining.
  FutureOr<T> catchError(OnRejected<T> onRejected) {
    return _future.catchError((Object error) async {
      try {
        return onRejected(error);
      } catch (e) {
        rethrow;
      }
    });
  }

  /// Creates a Promise that is resolved with null.
  static Promise<void> resolve() {
    return Promise<void>((resolve, _) => resolve(null));
  }

  /// Creates a Promise that is immediately rejected with the provided [error].
  static Promise<void> reject(Object error) {
    return Promise<void>((_, reject) => reject(error));
  }

  /// Takes a list of Promises and returns a new Promise that resolves
  /// when all of the Promises in the list have resolved, or rejects with the
  /// reason of the first rejected Promise in the list.
  static Promise<List<T>> all<T>(List<Promise<T>> promises) {
    return Promise<List<T>>((resolve, reject) {
      Future.wait(promises.map((p) => p._future))
          .then(resolve)
          .catchError(reject);
    });
  }

  /// Takes a list of Promises and returns a new Promise that either resolves
  /// or rejects as soon as one of the Promises in the list resolves or
  /// rejects, with the value or error of that Promise.
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

  /// Converts this Promise to a Future<T>, allowing for integration with other
  /// Dart async operations.
  Future<T> toFuture() {
    return _future;
  }
}
