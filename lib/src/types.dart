//
//  dart_promise
//  types.dart
//
//  Created by Ngonidzashe Mangudya on 13/06/2024.
//  Copyright (c) 2024 Codecraft Solutions. All rights reserved.
//

/// Type definition for the executor function used in the Promise constructor.
typedef Executor<T> = void Function(
  void Function(T value) resolve,
  void Function(Object error) reject,
);

/// Type definition for the function called when a Promise resolves successfully.
typedef OnFulfilled<T, TResult> = TResult Function(T value);

/// Type definition for the function called when a Promise is rejected.
typedef OnRejected<TResult> = TResult Function(Object error);
