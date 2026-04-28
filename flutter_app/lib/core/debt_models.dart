import 'package:flutter/material.dart';

enum DebtStatus { pendente, emPagamento, renegociada, quitada }
enum DebtType { unica, parcelada }
enum InstallmentStatus { pendente, paga, antecipada, emAtraso }

class DebtInstallment {
  final String id;
  final double originalAmount;
  double paidAmount;
  DateTime dueDate;
  DateTime? paymentDate;
  InstallmentStatus status;
  double discount; // Para economia gerada em antecipação

  DebtInstallment({
    required this.id,
    required this.originalAmount,
    this.paidAmount = 0.0,
    required this.dueDate,
    this.paymentDate,
    this.status = InstallmentStatus.pendente,
    this.discount = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalAmount': originalAmount,
    'paidAmount': paidAmount,
    'dueDate': dueDate.toIso8601String(),
    'paymentDate': paymentDate?.toIso8601String(),
    'status': status.index,
    'discount': discount,
  };

  factory DebtInstallment.fromJson(Map<String, dynamic> json) => DebtInstallment(
    id: json['id'],
    originalAmount: json['originalAmount'],
    paidAmount: json['paidAmount'] ?? 0.0,
    dueDate: DateTime.parse(json['dueDate']),
    paymentDate: json['paymentDate'] != null ? DateTime.parse(json['paymentDate']) : null,
    status: InstallmentStatus.values[json['status'] ?? 0],
    discount: json['discount'] ?? 0.0,
  );

  // Calcula se está em atraso em tempo real, se estiver pendente e o vencimento for no passado (ignorando a hora)
  InstallmentStatus get currentStatus {
    if (status == InstallmentStatus.pendente) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
      if (due.isBefore(today)) {
        return InstallmentStatus.emAtraso;
      }
    }
    return status;
  }
}

class DebtItem {
  final String id;
  String name;
  String creditor;
  double originalTotalAmount; // Valor total original
  DebtType type;
  double? interestRate; // Taxa de juros opcional
  DateTime originDate;
  DebtStatus status;
  
  List<DebtInstallment> installments;

  DebtItem({
    required this.id,
    required this.name,
    required this.creditor,
    required this.originalTotalAmount,
    required this.type,
    this.interestRate,
    required this.originDate,
    this.status = DebtStatus.pendente,
    required this.installments,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'creditor': creditor,
    'originalTotalAmount': originalTotalAmount,
    'type': type.index,
    'interestRate': interestRate,
    'originDate': originDate.toIso8601String(),
    'status': status.index,
    'installments': installments.map((e) => e.toJson()).toList(),
  };

  factory DebtItem.fromJson(Map<String, dynamic> json) => DebtItem(
    id: json['id'],
    name: json['name'],
    creditor: json['creditor'],
    originalTotalAmount: json['originalTotalAmount'],
    type: DebtType.values[json['type'] ?? 0],
    interestRate: json['interestRate'],
    originDate: DateTime.parse(json['originDate']),
    status: DebtStatus.values[json['status'] ?? 0],
    installments: (json['installments'] as List?)?.map((e) => DebtInstallment.fromJson(e)).toList() ?? [],
  );

  double get totalPaid {
    return installments.fold(0.0, (sum, item) => sum + item.paidAmount);
  }

  double get currentBalance {
    // Saldo devedor = (Soma das parcelas ativas com seus valores originais) - (Soma paga)
    // Para simplificar: Total original - valor pago. Se houver renegociação, a lógica muda levemente.
    double expectedTotal = installments.fold(0.0, (sum, item) {
      if (item.status == InstallmentStatus.antecipada) {
        return sum + item.paidAmount; // Se antecipou, o esperado cai
      }
      return sum + item.originalAmount;
    });
    return expectedTotal - totalPaid;
  }

  double get generatedEconomy {
    // Economia = soma dos descontos
    return installments.fold(0.0, (sum, item) => sum + item.discount);
  }

  double get progressPercentage {
    if (originalTotalAmount == 0) return 0;
    return (totalPaid / originalTotalAmount).clamp(0.0, 1.0);
  }
}
