import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'auth_service.dart';
import 'subscription_service.dart';

class InAppPurchaseService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final AuthService _authService = AuthService();
  final SubscriptionService _subscriptionService = SubscriptionService();

  // IDs des produits (doivent correspondre à ceux configurés dans les stores)
  static const Set<String> _productIds = {
    'premium_basic_monthly',
    'premium_basic_yearly',
    'premium_pro_monthly',
    'premium_pro_yearly',
  };

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  // Initialiser le service
  Future<void> initialize() async {
    // Vérifier si les achats in-app sont disponibles
    _isAvailable = await _inAppPurchase.isAvailable();

    if (!_isAvailable) {
      print('In-App Purchases non disponibles');
      return;
    }

    // Configurer le listener pour iOS
    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition =
          _inAppPurchase
              .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      // Delegate désactivé temporairement pour éviter les erreurs de compilation
      // await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    // Écouter les changements de statut d'achat
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Erreur purchase stream: $error'),
    );

    // Charger les produits disponibles
    await _loadProducts();
  }

  // Charger les produits depuis les stores
  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(_productIds);

      if (response.notFoundIDs.isNotEmpty) {
        print('Produits non trouvés: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      print('${_products.length} produits chargés');
    } catch (e) {
      print('Erreur lors du chargement des produits: $e');
    }
  }

  // Obtenir la liste des produits
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  // Acheter un produit
  Future<bool> buyProduct(ProductDetails product) async {
    if (!_isAvailable) {
      throw Exception('Achats in-app non disponibles');
    }

    try {
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: await _getUserId(),
      );

      bool success;
      if (product.id.contains('monthly') || product.id.contains('yearly')) {
        // Abonnement
        success = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        // Achat unique
        success = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
        );
      }

      return success;
    } catch (e) {
      print('Erreur lors de l\'achat: $e');
      throw Exception('Erreur lors de l\'achat: $e');
    }
  }

  // Restaurer les achats
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Erreur lors de la restauration: $e');
      throw Exception('Erreur lors de la restauration: $e');
    }
  }

  // Gérer les mises à jour d'achat
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _handlePurchase(purchaseDetails);
    }
  }

  // Traiter un achat
  Future<void> _handlePurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.status) {
      case PurchaseStatus.pending:
        print('Achat en attente: ${purchaseDetails.productID}');
        break;

      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        print('Achat réussi: ${purchaseDetails.productID}');
        await _processPurchase(purchaseDetails);
        break;

      case PurchaseStatus.error:
        print('Erreur d\'achat: ${purchaseDetails.error}');
        break;

      case PurchaseStatus.canceled:
        print('Achat annulé: ${purchaseDetails.productID}');
        break;
    }

    // Finaliser l'achat (obligatoire)
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  // Traiter l'achat côté serveur
  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // Envoyer les données d'achat au serveur pour validation
      final result = await _subscriptionService.validateStorePurchase(
        productId: purchaseDetails.productID,
        purchaseToken: purchaseDetails.verificationData.serverVerificationData,
        platform: Platform.isIOS ? 'ios' : 'android',
      );

      if (result['success'] == true) {
        print('Abonnement activé avec succès');
      } else {
        print('Erreur lors de l\'activation: ${result['message']}');
      }
    } catch (e) {
      print('Erreur lors du traitement serveur: $e');
    }
  }

  // Obtenir l'ID utilisateur
  Future<String?> _getUserId() async {
    try {
      final userData = await _authService.getUserData();
      return userData?['id']?.toString();
    } catch (e) {
      return null;
    }
  }

  // Obtenir le prix formaté d'un produit
  String getFormattedPrice(ProductDetails product) {
    return product.price;
  }

  // Vérifier si un produit est un abonnement annuel
  bool isYearlyProduct(ProductDetails product) {
    return product.id.contains('yearly');
  }

  // Vérifier si un produit est Premium Pro
  bool isProProduct(ProductDetails product) {
    return product.id.contains('pro');
  }

  // Disposer du service
  void dispose() {
    _subscription.cancel();
  }
}

// Delegate pour iOS (requis pour les abonnements)
// Temporairement désactivé pour éviter les erreurs de compilation
/*
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
    SKPaymentTransactionWrapper transaction,
    SKStorefrontWrapper storefront,
  ) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
*/
