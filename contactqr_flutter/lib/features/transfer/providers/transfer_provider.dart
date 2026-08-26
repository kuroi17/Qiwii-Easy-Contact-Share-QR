import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/local_transfer_client.dart';

final transferClientProvider = Provider<LocalTransferClient>((ref) {
  return const LocalTransferClient();
});
