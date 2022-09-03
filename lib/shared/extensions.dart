import 'package:dict/shared/models.dart';

extension RoutingExt on String {
  RoutingData get routingData => RoutingData.fromUri(Uri.parse(this));
}
