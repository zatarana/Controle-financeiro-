import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/finance_provider.dart';
import '../core/finance_models.dart';
import '../core/debt_models.dart';

class DebtDetailPage extends StatefulWidget {
  final String debtId;
  const DebtDetailPage({super.key, required this.debtId});

  @override
  State<DebtDetailPage> createState() => _DebtDetailPageState();
}

class _DebtDetailPageState extends State<DebtDetailPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final index = provider.advancedDebts.indexWhere((element) => element.id == widget.debtId);
    
    if (index == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalhes da Dívida')),
        body: const Center(child: Text('Dívida não encontrada')),
      );
    }
    
    final debt = provider.advancedDebts[index];
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(debt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status and Start Payment Button
            if (debt.status == DebtStatus.pendente)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFDE68A))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD97706), size: 20),
                        SizedBox(width: 8),
                        Text('Dívida Pendente', style: TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text('Esta dívida ainda não afeta seu orçamento e não exibe lembretes.', style: TextStyle(color: Color(0xFFB45309), fontSize: 13)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD97706),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        provider.startPaymentOfDebt(debt.id);
                      },
                      child: const Text('Iniciar Pagamento', style: TextStyle(fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            
            // Renegotiation Button logic
            if (debt.status != DebtStatus.quitada)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                child: OutlinedButton.icon(
                  onPressed: () => _showRenegotiateDialog(context, debt),
                  icon: const Icon(Icons.handshake_outlined),
                  label: const Text('Renegociar Dívida'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.purple,
                    side: const BorderSide(color: Colors.purple),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),

            // Indicators Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Painel Financeiro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIndicator('Valor Original', currencyFormat.format(debt.originalTotalAmount), Colors.black87),
                      _buildIndicator('Saldo Devedor', currencyFormat.format(debt.currentBalance), Colors.red),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildIndicator('Total Já Pago', currencyFormat.format(debt.totalPaid), Colors.green),
                      _buildIndicator('Economia/Desconto', currencyFormat.format(debt.generatedEconomy), Colors.green, isPositive: true),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Progress Bar
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE5E7EB))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Progresso de Quitação', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\${(debt.progressPercentage * 100).toStringAsFixed(1)}% Pago', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text(debt.status == DebtStatus.quitada ? 'Quitação concluída' : 'Faltam \${currencyFormat.format(debt.currentBalance)}', style: const TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: debt.progressPercentage,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: AlwaysStoppedAnimation<Color>(debt.status == DebtStatus.quitada ? Colors.green : Colors.blue),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFF3F4F6), height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat('Pagas', debt.installments.where((e) => e.status == InstallmentStatus.paga).length.toString(), Colors.blue),
                      _buildMiniStat('Atraso', debt.installments.where((e) => e.currentStatus == InstallmentStatus.emAtraso).length.toString(), Colors.red),
                      _buildMiniStat('Antecip.', debt.installments.where((e) => e.status == InstallmentStatus.antecipada).length.toString(), Colors.purple),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            const Text('Parcelas / Histórico', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: debt.installments.length,
              itemBuilder: (context, idx) {
                final inst = debt.installments[idx];
                final instStatus = inst.currentStatus;
                
                Color sColor = Colors.orange;
                String sText = 'Pendente';
                if (instStatus == InstallmentStatus.paga) { sColor = Colors.blue; sText = 'Paga'; }
                else if (instStatus == InstallmentStatus.emAtraso) { sColor = Colors.red; sText = 'Atrasada'; }
                else if (instStatus == InstallmentStatus.antecipada) { sColor = Colors.purple; sText = 'Antecipada'; }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF3F4F6))
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: sColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Text('\${idx + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: sColor)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currencyFormat.format(inst.originalAmount), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, decoration: instStatus == InstallmentStatus.paga || instStatus == InstallmentStatus.antecipada ? TextDecoration.lineThrough : null)),
                            const SizedBox(height: 4),
                            Text('Venc: \${DateFormat("dd/MM/yyyy").format(inst.dueDate)}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      if (instStatus == InstallmentStatus.pendente || instStatus == InstallmentStatus.emAtraso) 
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          onPressed: () => _showPayDialog(context, debt, inst),
                          child: const Text('Pagar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        )
                      else 
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: sColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(sText, style: TextStyle(color: sColor, fontWeight: FontWeight.bold, fontSize: 10)),
                        )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIndicator(String label, String value, Color valueColor, {bool isPositive = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isPositive) const Icon(Icons.arrow_downward, color: Colors.green, size: 14),
            Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showPayDialog(BuildContext context, DebtItem debt, DebtInstallment inst) {
    if (debt.status == DebtStatus.pendente) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicie o pagamento da dívida primeiro.')));
      return;
    }

    final valCtrl = TextEditingController(text: inst.originalAmount.toStringAsFixed(2));
    bool isAntecipacao = debt.interestRate != null && debt.interestRate! > 0 && inst.dueDate.isAfter(DateTime.now());
    
    showDialog(
      context: context, 
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isAntecipacao ? 'Antecipar Parcela' : 'Pagar Parcela', style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAntecipacao)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(8)),
                child: const Text('Ótimo! Antecipar gera desconto de juros.', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            TextField(
              controller: valCtrl,
              decoration: const InputDecoration(labelText: 'Valor Pago (R\$)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
            onPressed: () {
              double paidAmount = double.tryParse(valCtrl.text.replaceAll(',', '.')) ?? 0;
              if (paidAmount > 0) {
                inst.paidAmount = paidAmount;
                inst.paymentDate = DateTime.now();
                
                if (isAntecipacao && paidAmount < inst.originalAmount) {
                  inst.status = InstallmentStatus.antecipada;
                  inst.discount = inst.originalAmount - paidAmount;
                } else {
                  inst.status = InstallmentStatus.paga;
                }

                provider.updateAdvancedDebt(debt.id, debt);

                // Add to transactions history
                provider.addTransaction(AppFinanceTransaction(
                  id: DateTime.now().toString(),
                  title: 'Pagamento: ${debt.name}',
                  amount: paidAmount,
                  releaseDate: DateTime.now(),
                  dueDate: DateTime.now(),
                  effectiveDate: DateTime.now(),
                  type: TransactionType.expense,
                ));

                // Check if all are paid
                if (debt.installments.every((e) => e.status == InstallmentStatus.paga || e.status == InstallmentStatus.antecipada)) {
                  debt.status = DebtStatus.quitada;
                  provider.updateAdvancedDebt(debt.id, debt);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Parabéns! Dívida quitada! 🎉'), backgroundColor: Colors.green));
                }

                Navigator.pop(ctx);
                setState(() {});
              }
            }, 
            child: const Text('Confirmar Pagamento')
          )
        ],
      )
    );
  }

  void _showRenegotiateDialog(BuildContext context, DebtItem debt) {
    bool isParcelada = debt.type == DebtType.parcelada;
    final valCtrl = TextEditingController(text: debt.currentBalance.toStringAsFixed(2));
    final installmentsCtrl = TextEditingController(text: isParcelada ? '1' : '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Renegociar Dívida', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Saldo Atual: R\$ \${debt.currentBalance.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateBuilder(() => isParcelada = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isParcelada ? const Color(0xFFF0FDF4) : const Color(0xFFF9FAFB),
                          border: Border.all(color: !isParcelada ? Colors.green : Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        alignment: Alignment.center,
                        child: Text('À vista', style: TextStyle(color: !isParcelada ? Colors.green : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setStateBuilder(() => isParcelada = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isParcelada ? const Color(0xFFEFF6FF) : const Color(0xFFF9FAFB),
                          border: Border.all(color: isParcelada ? Colors.blue : Colors.transparent),
                          borderRadius: BorderRadius.circular(12)
                        ),
                        alignment: Alignment.center,
                        child: Text('Parcelado', style: TextStyle(color: isParcelada ? Colors.blue : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: valCtrl,
                decoration: const InputDecoration(labelText: 'Novo Valor Total (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              if (isParcelada)
                TextField(
                  controller: installmentsCtrl,
                  decoration: const InputDecoration(labelText: 'Novas Parcelas'),
                  keyboardType: TextInputType.number,
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.black54))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
              onPressed: () {
                double newTotal = double.tryParse(valCtrl.text.replaceAll(',', '.')) ?? 0;
                int newInstallmentsCount = isParcelada ? (int.tryParse(installmentsCtrl.text) ?? 1) : 1;

                if (newTotal > 0 && newInstallmentsCount > 0) {
                  // Mark pending parts as renegotiated/paid out or just replace them
                  debt.installments.removeWhere((element) => element.status == InstallmentStatus.pendente || element.status == InstallmentStatus.emAtraso);
                  
                  final newInstallmentAmount = newTotal / newInstallmentsCount;
                  final now = DateTime.now();

                  for (int i = 0; i < newInstallmentsCount; i++) {
                    debt.installments.add(DebtInstallment(
                      id: '\${now.millisecondsSinceEpoch}_reneg_$i',
                      originalAmount: newInstallmentAmount,
                      dueDate: DateTime(now.year, now.month + 1 + i, now.day), 
                      status: InstallmentStatus.pendente,
                    ));
                  }

                  // Calculate internal logic to represent economy or added cost
                  // The generated economy logic on the model might need adjusting, but a basic approach is replacing installments
                  
                  debt.status = DebtStatus.renegociada;
                  debt.type = isParcelada ? DebtType.parcelada : DebtType.unica;
                  provider.updateAdvancedDebt(debt.id, debt);
                  
                  Navigator.pop(ctx);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dívida renegociada com sucesso!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.purple));
                }
              }, 
              child: const Text('Salvar')
            )
          ],
        )
      )
    );
  }

  FinanceProvider get provider => context.read<FinanceProvider>();
}
