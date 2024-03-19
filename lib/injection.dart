import 'package:get_it/get_it.dart';
import 'package:smth_about_bank/better_solution/cubit/bank_cubit.dart';
import 'package:smth_about_bank/loader.dart';

final GetIt getIt = GetIt.instance;

void initializeInjection() {
  // Cubits
  getIt.registerFactory<BankCubit>(() => BankCubit(getIt.get()));

  // Services
  getIt.registerFactory<IRandomService>(() => const RandomService());
}
