import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'facturation_model.g.dart';

@HiveType(typeId: 8)
class Facturation extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String factureNumber;
  
  @HiveField(2)
  final String clientFactureId; // Client who receives the invoice
  
  @HiveField(3)
  final String clientSourceId; // Client who received the goods
  
  @HiveField(4)
  final DateTime dateFacture;
  
  @HiveField(5)
  final List<String> blReferences; // List of BL IDs included in this invoice
  
  @HiveField(6)
  final double totalAmount;
  
  @HiveField(7)
  final String status; // 'brouillon', 'valide', 'envoye', 'paye', 'annule'
  
  @HiveField(8)
  final DateTime? datePaiement;
  
  @HiveField(9)
  final String? commentaires;
  
  @HiveField(10)
  final DateTime dateCreation;
  
  @HiveField(11)
  final DateTime dateModification;

  Facturation({
    String? id,
    required this.factureNumber,
    required this.clientFactureId,
    required this.clientSourceId,
    required this.dateFacture,
    required this.blReferences,
    required this.totalAmount,
    this.status = 'brouillon',
    this.datePaiement,
    this.commentaires,
    DateTime? dateCreation,
    DateTime? dateModification,
  }) : id = id ?? const Uuid().v4(),
       dateCreation = dateCreation ?? DateTime.now(),
       dateModification = dateModification ?? DateTime.now();

  // Create a copy with updated fields
  Facturation copyWith({
    String? factureNumber,
    String? clientFactureId,
    String? clientSourceId,
    DateTime? dateFacture,
    List<String>? blReferences,
    double? totalAmount,
    String? status,
    DateTime? datePaiement,
    String? commentaires,
    DateTime? dateModification,
  }) {
    return Facturation(
      id: id,
      factureNumber: factureNumber ?? this.factureNumber,
      clientFactureId: clientFactureId ?? this.clientFactureId,
      clientSourceId: clientSourceId ?? this.clientSourceId,
      dateFacture: dateFacture ?? this.dateFacture,
      blReferences: blReferences ?? this.blReferences,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      datePaiement: datePaiement ?? this.datePaiement,
      commentaires: commentaires ?? this.commentaires,
      dateCreation: dateCreation,
      dateModification: dateModification ?? DateTime.now(),
    );
  }

  // Check if this is a "facturation à un tiers" (third-party billing)
  bool get isThirdPartyBilling => clientFactureId != clientSourceId;
  
  // Check if invoice is editable
  bool get isEditable => status == 'brouillon';
  
  // Check if invoice is paid
  bool get isPaid => status == 'paye';
  
  // Check if invoice is cancelled
  bool get isCancelled => status == 'annule';
  
  // Get status display text
  String get statusText {
    switch (status) {
      case 'brouillon':
        return 'Brouillon';
      case 'valide':
        return 'Validée';
      case 'envoye':
        return 'Envoyée';
      case 'paye':
        return 'Payée';
      case 'annule':
        return 'Annulée';
      default:
        return status;
    }
  }
  
  // Get status color
  String get statusColor {
    switch (status) {
      case 'brouillon':
        return 'orange';
      case 'valide':
        return 'blue';
      case 'envoye':
        return 'purple';
      case 'paye':
        return 'green';
      case 'annule':
        return 'red';
      default:
        return 'grey';
    }
  }

  @override
  String toString() {
    return 'Facturation(id: $id, factureNumber: $factureNumber, clientFactureId: $clientFactureId, '
           'clientSourceId: $clientSourceId, totalAmount: $totalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Facturation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Helper class for invoice line items (derived from BL data)
class FactureLineItem {
  final String articleReference;
  final String articleDesignation;
  final String treatmentId;
  final String treatmentName;
  final int quantity;
  final double prixUnitaire;
  final double total;
  final String blReference;

  FactureLineItem({
    required this.articleReference,
    required this.articleDesignation,
    required this.treatmentId,
    required this.treatmentName,
    required this.quantity,
    required this.prixUnitaire,
    required this.total,
    required this.blReference,
  });

  @override
  String toString() {
    return 'FactureLineItem(article: $articleReference, treatment: $treatmentName, '
           'qty: $quantity, prix: $prixUnitaire, total: $total, bl: $blReference)';
  }
}