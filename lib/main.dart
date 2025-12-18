import 'package:flutter/material.dart';
import 'package:flutter_rust_wallet/src/rust/api/balance.dart';
import 'package:flutter_rust_wallet/src/rust/api/db.dart';
import 'package:flutter_rust_wallet/src/rust/api/wallet.dart';
import 'package:flutter_rust_wallet/src/rust/frb_generated.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();

  final dir = await getApplicationSupportDirectory();
  final path = join(dir.path, 'tari-wallet.db');

  debugPrint('DB PATH: $path');

  await initializeDatabase(path: path);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WalletCreationDetails? wallet;
  String? balanceResult;
  bool loading = false;

  final TextEditingController seedController = TextEditingController();

  void _showError(Object e) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }

  Future<void> _createWallet() async {
    setState(() => loading = true);
    try {
      wallet = await createWallet();
      setState(() {});
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Future<void> _checkBalance() async {
    if (wallet == null) return;
    setState(() => loading = true);
    try {
      balanceResult = (await getBalance(name: '')).toString();
      setState(() {});
    } catch (e) {
      _showError(e);
    } finally {
      setState(() => loading = false);
    }
  }

  Widget _walletDetails() {
    if (wallet == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Address: ${wallet!.tariAddress}'),
        Text('Birthday: ${wallet!.walletBirthday}'),
        Text('Spend Key: ${wallet!.spendPublicKeyHex}'),
        Text('View Key: ${wallet!.viewPrivateKeyHex}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Tari Wallet Demo')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Create Wallet', style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: loading ? null : _createWallet,
                child: const Text('Create New Wallet'),
              ),
              _walletDetails(),
              const Divider(),
              const Text('Balance', style: TextStyle(fontSize: 18)),
              ElevatedButton(
                onPressed: loading ? null : _checkBalance,
                child: const Text('Check Balance'),
              ),
              if (balanceResult != null) Text('Balance: $balanceResult'),
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
