class RoutingData {
  final String path;
  final Map<String, String> _params;

  RoutingData(this.path, {required Map<String, String> params})
      : _params = params;

  factory RoutingData.fromUri(Uri uri) {
    return RoutingData(uri.path, params: uri.queryParameters);
  }

  factory RoutingData.fromString(String uri) {
    final List<String> parts = uri.split('?');
    final String route = parts[0];
    final Map<String, String> params = {};
    if (parts.length > 1) {
      final String query = parts[1];
      for (final String param in query.split('&')) {
        final List<String> keyValue = param.split('=');
        if (keyValue.length == 2) {
          params[keyValue[0]] = keyValue[1];
        }
      }
    }
    return RoutingData(route, params: params);
  }

  operator [](String key) => _params[key];

  String toString() =>
      '$path?${_params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

  Uri toUri() => Uri(path: path, queryParameters: _params);
}
