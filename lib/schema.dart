class Schema {
  final String _key;
  final String _type;

  String get key => _key;
  String get type => _type;

  Schema(this._key, this._type);

  String toString() {
    return "key: $_key\ntype: $type";
  }
}
