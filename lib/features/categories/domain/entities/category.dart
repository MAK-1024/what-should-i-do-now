import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';


@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    String? color,
    String? icon,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
