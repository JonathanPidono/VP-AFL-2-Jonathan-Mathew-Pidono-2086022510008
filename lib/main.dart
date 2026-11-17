import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/card_repository_impl.dart';
import 'data/services/card_data_source.dart';
import 'data/services/local_card_service.dart';
import 'data/services/seed_loader.dart';
import 'domain/models/tcg_card.dart';
import 'domain/repositories/card_repository.dart';
import 'viewmodels/detail_view_model.dart';
import 'viewmodels/form_view_model.dart';
import 'viewmodels/vault_view_model.dart';
import 'views/detail/card_detail_screen.dart';
import 'views/form/card_form_screen.dart';
import 'views/vault/vault_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final CardDataSource source = await LocalCardService.open();

  final CardRepository repository = CardRepositoryImpl(
    source: source,
    seed: SeedLoader(),
  );

  Widget formPage([TcgCard? card]) => CardFormScreen(
        createViewModel: () => FormViewModel(repository, card: card),
      );

  Widget detailPage(String cardId) => CardDetailScreen(
        createViewModel: () => DetailViewModel(repository, cardId),
        formPageBuilder: formPage,
      );

  runApp(
    TcgVaultApp(
      vaultViewModel: VaultViewModel(repository)..load(),
      detailPageBuilder: detailPage,
      formPageBuilder: formPage,
    ),
  );
}

class TcgVaultApp extends StatefulWidget {
  const TcgVaultApp({
    super.key,
    required this.vaultViewModel,
    required this.detailPageBuilder,
    required this.formPageBuilder,
  });

  final VaultViewModel vaultViewModel;
  final Widget Function(String cardId) detailPageBuilder;
  final Widget Function([TcgCard? card]) formPageBuilder;

  @override
  State<TcgVaultApp> createState() => _TcgVaultAppState();
}

class _TcgVaultAppState extends State<TcgVaultApp> {
  @override
  void dispose() {
    widget.vaultViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TCG Vault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: VaultScreen(
        viewModel: widget.vaultViewModel,
        detailPageBuilder: widget.detailPageBuilder,
        formPageBuilder: widget.formPageBuilder,
      ),
    );
  }
}
