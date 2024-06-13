import 'package:dart_promise/dart_promise.dart';
import 'package:test/test.dart';

void main() {
  group('Promise Tests', () {
    test('Promise resolves correctly and prints the value', () async {
      final promise = Promise<int>((resolve, reject) {
        resolve(10);
      });

      await expectLater(promise.toFuture(), completion(equals(10)));
    });

    test('Promise rejects correctly', () async {
      final promise = Promise<int>((resolve, reject) {
        reject('Error');
      });

      final future = promise.toFuture();

      await expectLater(future, throwsA(isA<String>()));
    });

    test('Promise chain with then', () async {
      final promise = Promise<int>((resolve, reject) {
        resolve(5);
      }).then((value) => 'Result: $value');

      await expectLater(promise.toFuture(), completion(equals('Result: 5')));
    });

    test('CatchError handles rejection', () async {
      var errorHandled = false;
      final promise = Promise<int>((resolve, reject) {
        reject('Initial error');
      }).catchError((error) {
        errorHandled = true;
        return 0;
      });

      final _ = await promise;
      expect(errorHandled, isTrue);
    });

    test('Promise.all resolves correctly', () async {
      final promise1 = Promise<int>((resolve, reject) => resolve(1));
      final promise2 = Promise<int>((resolve, reject) => resolve(2));
      final combined = Promise.all([promise1, promise2]);

      await expectLater(combined.toFuture(), completion(equals([1, 2])));
    });

    test('Promise.race resolves correctly', () async {
      final promise1 = Promise<int>(
        (resolve, reject) =>
            Future.delayed(const Duration(seconds: 1), () => resolve(1)),
      );
      final promise2 = Promise<int>(
        (resolve, reject) =>
            Future.delayed(const Duration(seconds: 2), () => resolve(2)),
      );
      final winner = Promise.race([promise1, promise2]);

      await expectLater(winner.toFuture(), completion(equals(1)));
    });
  });
}
