import 'package:flutter/material.dart';

enum AccountType { checking, savings, investment, wallet, loan } // Loan = conta de empréstimo (citada no doc)

class FinanceAccount {
  final String id;
  String name;
  double initialBalance;
  double currentBalance;
  AccountType type;
  bool ignoreInTotals; // Ignorar nos totais
  bool isDefault; // Bolinha verde vivo
  String colorHex;

  FinanceAccount({
    required this.id,
    required this.name,
    required this.initialBalance,
    required this.currentBalance,
    this.type = AccountType.checking,
    this.ignoreInTotals = false,
    this.isDefault = false,
    this.colorHex = '#000000',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialBalance': initialBalance,
    'currentBalance': currentBalance,
    'type': type.index,
    'ignoreInTotals': ignoreInTotals,
    'isDefault': isDefault,
    'colorHex': colorHex,
  };

  factory FinanceAccount.fromJson(Map<String, dynamic> json) => FinanceAccount(
    id: json['id'],
    name: json['name'],
    initialBalance: json['initialBalance'] ?? 0.0,
    currentBalance: json['currentBalance'] ?? 0.0,
    type: AccountType.values[json['type'] ?? 0],
    ignoreInTotals: json['ignoreInTotals'] ?? false,
    isDefault: json['isDefault'] ?? false,
    colorHex: json['colorHex'] ?? '#000000',
  );
}

enum CategoryType { income, expense, transfer }

class FinanceSubcategory {
  final String id;
  String name;
  
  FinanceSubcategory({required this.id, required this.name});
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
  
  factory FinanceSubcategory.fromJson(Map<String, dynamic> json) => FinanceSubcategory(
    id: json['id'],
    name: json['name'],
  );
}

class FinanceCategory {
  final String id;
  String name;
  CategoryType type;
  List<FinanceSubcategory> subcategories; // Toda categ tem 'Outros' por padrão.
  String colorHex;
  String iconName; 

  FinanceCategory({
    required this.id,
    required this.name,
    required this.type,
    this.subcategories = const [],
    this.colorHex = '#000000',
    this.iconName = 'category',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'subcategories': subcategories.map((e) => e.toJson()).toList(),
    'colorHex': colorHex,
    'iconName': iconName,
  };

  factory FinanceCategory.fromJson(Map<String, dynamic> json) => FinanceCategory(
    id: json['id'],
    name: json['name'],
    type: CategoryType.values[json['type'] ?? 0],
    subcategories: (json['subcategories'] as List?)?.map((e) => FinanceSubcategory.fromJson(e)).toList() ?? [],
    colorHex: json['colorHex'] ?? '#000000',
    iconName: json['iconName'] ?? 'category',
  );
}

class CreditCard {
  final String id;
  String name;
  double limit;
  int closingDay;
  int dueDay;
  String defaultAccountId;

  CreditCard({
    required this.id,
    required this.name,
    required this.limit,
    required this.closingDay,
    required this.dueDay,
    required this.defaultAccountId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'limit': limit,
    'closingDay': closingDay,
    'dueDay': dueDay,
    'defaultAccountId': defaultAccountId,
  };

  factory CreditCard.fromJson(Map<String, dynamic> json) => CreditCard(
    id: json['id'],
    name: json['name'],
    limit: json['limit'] ?? 0.0,
    closingDay: json['closingDay'] ?? 1,
    dueDay: json['dueDay'] ?? 5,
    defaultAccountId: json['defaultAccountId'] ?? '',
  );
}

enum TransactionType { income, expense, transfer, creditCardExpense }
enum RecurrenceType { none, fixed_monthly, installments }

class TransactionMultiCategory {
   String categoryId;
   String? subcategoryId;
   double amount;
   String? note;

   TransactionMultiCategory({required this.categoryId, this.subcategoryId, required this.amount, this.note});
   
   Map<String, dynamic> toJson() => {
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'amount': amount,
    'note': note,
   };

   factory TransactionMultiCategory.fromJson(Map<String, dynamic> json) => TransactionMultiCategory(
    categoryId: json['categoryId'],
    subcategoryId: json['subcategoryId'],
    amount: json['amount'],
    note: json['note'],
   );
}

class AppFinanceTransaction {
  final String id;
  String title; // Descrição (máx 35 chars no doc)
  double amount;
  
  // As três datas do manual
  DateTime releaseDate;   // Data de lançamento
  DateTime dueDate;       // Data de vencimento
  DateTime? effectiveDate;// Data de efetivação
  
  TransactionType type;
  bool isPaid; // Efetivada/Pendente
  
  String? accountId;
  String? destinationAccountId; // Para Transferências
  String? categoryId;
  String? subcategoryId;
  
  String? creditCardId; // Vínculo ao cartão

  RecurrenceType recurrence; // Não recorrente, Fixa mensal ou Parcelada
  int parcelCount;
  int currentParcel;

  String? notes; // max 2000 caracteres, aceita tags/hashtags textuais manual = "#viagem"
  List<String> tags; // Etiquetas 
  String? attachmentPath; // Imagem/PDF no mobile

  // Campos Avançados Citados no PDF
  bool ignoreInStats; // Ignorar em Estatísticas e Gráficos
  bool ignoreInMonthlyEconomy; // Ignorar em Economia Mensal
  bool ignoreInTotals; // Ignorar nos Totais
  bool ignoreInCreditCardLimit; // Ignorar no Limite do Cartão

  List<TransactionMultiCategory>? multiCategories; // Rateios

  AppFinanceTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.releaseDate,
    required this.dueDate,
    this.effectiveDate,
    required this.type,
    this.isPaid = true,
    this.accountId,
    this.destinationAccountId,
    this.categoryId,
    this.subcategoryId,
    this.creditCardId,
    this.recurrence = RecurrenceType.none,
    this.parcelCount = 1,
    this.currentParcel = 1,
    this.notes,
    this.tags = const [],
    this.attachmentPath,
    this.ignoreInStats = false,
    this.ignoreInMonthlyEconomy = false,
    this.ignoreInTotals = false,
    this.ignoreInCreditCardLimit = false,
    this.multiCategories,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'amount': amount,
    'releaseDate': releaseDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'effectiveDate': effectiveDate?.toIso8601String(),
    'type': type.index,
    'isPaid': isPaid,
    'accountId': accountId,
    'destinationAccountId': destinationAccountId,
    'categoryId': categoryId,
    'subcategoryId': subcategoryId,
    'creditCardId': creditCardId,
    'recurrence': recurrence.index,
    'parcelCount': parcelCount,
    'currentParcel': currentParcel,
    'notes': notes,
    'tags': tags,
    'attachmentPath': attachmentPath,
    'ignoreInStats': ignoreInStats,
    'ignoreInMonthlyEconomy': ignoreInMonthlyEconomy,
    'ignoreInTotals': ignoreInTotals,
    'ignoreInCreditCardLimit': ignoreInCreditCardLimit,
    'multiCategories': multiCategories?.map((e) => e.toJson()).toList(),
  };

  factory AppFinanceTransaction.fromJson(Map<String, dynamic> json) => AppFinanceTransaction(
    id: json['id'],
    title: json['title'],
    amount: json['amount'] ?? 0.0,
    releaseDate: json['releaseDate'] != null ? DateTime.parse(json['releaseDate']) : DateTime.parse(json['date']), // Fallback pra versões anter.
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.parse(json['date']),
    effectiveDate: json['effectiveDate'] != null ? DateTime.parse(json['effectiveDate']) : null,
    type: TransactionType.values[json['type'] ?? 0],
    isPaid: json['isPaid'] ?? true,
    accountId: json['accountId'],
    destinationAccountId: json['destinationAccountId'],
    categoryId: json['categoryId'],
    subcategoryId: json['subcategoryId'],
    creditCardId: json['creditCardId'],
    recurrence: RecurrenceType.values[json['recurrence'] ?? 0],
    parcelCount: json['parcelCount'] ?? 1,
    currentParcel: json['currentParcel'] ?? 1,
    notes: json['notes'],
    tags: List<String>.from(json['tags'] ?? []),
    attachmentPath: json['attachmentPath'],
    ignoreInStats: json['ignoreInStats'] ?? false,
    ignoreInMonthlyEconomy: json['ignoreInMonthlyEconomy'] ?? false,
    ignoreInTotals: json['ignoreInTotals'] ?? false,
    ignoreInCreditCardLimit: json['ignoreInCreditCardLimit'] ?? false,
    multiCategories: (json['multiCategories'] as List?)?.map((e) => TransactionMultiCategory.fromJson(e)).toList(),
  );
}
