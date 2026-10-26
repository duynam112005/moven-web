# 3. Use Freezed and Build Runner for Immutable Models and State

## Context
Writing manual Dart model classes with boilerplate `copyWith`, `operator ==`, `hashCode`, `toString`, and JSON serialization is tedious and error-prone, particularly when maintaining complex state trees and domain models with multiple fields. Inconsistencies in copyWith or value equality lead to unnecessary UI rebuilds or subtle state bugs in Riverpod.

## Decision
1. Adopt `freezed` and `json_serializable` as the standard code generation solution for immutable data models, domain entities, and complex Riverpod state classes across MOVEN.
2. Structure model files with standard Freezed annotations:
   ```dart
   import 'package:freezed_annotation/freezed_annotation.dart';

   part '<filename>.freezed.dart';
   part '<filename>.g.dart'; // when JSON serialization is required

   @freezed
   class <ClassName> with _$<ClassName> {
     const factory <ClassName>({
       required String id,
       ...
     }) = _<ClassName>;

     factory <ClassName>.fromJson(Map<String, dynamic> json) =>
         _$<ClassName>FromJson(json);
   }
   ```
3. Code generation commands:
   - Use `dart run build_runner build --delete-conflicting-outputs` to generate or update code.
   - Generated files (`*.freezed.dart`, `*.g.dart`) must never be modified manually.

## Consequences
- Guarantees 100% deep immutability and accurate value equality out-of-the-box.
- Prevents boilerplate bugs in manual `copyWith` and JSON mapping.
- Requires running `build_runner` when model definitions change.
