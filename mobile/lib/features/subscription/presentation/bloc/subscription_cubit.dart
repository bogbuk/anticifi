import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../data/datasources/revenuecat_datasource.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository _repository;
  final RevenueCatDataSource _revenueCatDataSource;

  SubscriptionCubit(this._repository, this._revenueCatDataSource)
      : super(const SubscriptionInitial());

  Future<void> loadSubscription() async {
    emit(const SubscriptionLoading());
    try {
      final subscription = await _repository.getSubscriptionStatus();
      List<Package> packages = [];
      try {
        packages = await _revenueCatDataSource.getOfferings();
      } catch (_) {
        // Offerings may fail in dev/simulator
      }
      emit(SubscriptionLoaded(subscription: subscription, packages: packages));
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> purchasePackage(String packageId) async {
    emit(const SubscriptionPurchasing());
    try {
      await _repository.purchasePackage(packageId);
      await loadSubscription();
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        await loadSubscription();
      } else {
        emit(SubscriptionError(e.toString()));
      }
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }

  Future<void> restorePurchases() async {
    emit(const SubscriptionLoading());
    try {
      await _repository.restorePurchases();
      await loadSubscription();
    } catch (e) {
      emit(SubscriptionError(e.toString()));
    }
  }
}
