//
//  dart_promise
//  types.dart
//
//  Created by Ngonidzashe Mangudya on 13/06/2024.
//  Copyright (c) 2024 Codecraft Solutions. All rights reserved.
//

typedef Executor<T> = void Function(
  void Function(T value) resolve,
  void Function(Object error) reject,
);

typedef OnFulfilled<T, TResult> = TResult Function(T value);

typedef OnRejected<TResult> = TResult Function(Object error);
