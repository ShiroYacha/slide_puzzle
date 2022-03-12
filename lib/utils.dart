// ignore_for_file: public_member_api_docs

class NullableCopy<T> {
  const NullableCopy(this.data);

  final T? data;

  static T? resolve<T>(NullableCopy<T>? value, {T? orElse}) {
    if (value == null) return orElse;
    return value.isNull ? null : value.data;
  }

  bool get isNull => data == null;
}
