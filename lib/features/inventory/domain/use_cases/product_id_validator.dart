void validateProductId(String id, {String parameterName = 'id'}) {
  if (id.trim().isEmpty) {
    throw ArgumentError.value(id, parameterName, 'A product ID is required.');
  }
}
