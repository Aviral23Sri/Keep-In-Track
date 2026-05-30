// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      type: fields[1] as String,
      amount: fields[2] as double,
      categoryId: fields[3] as String,
      title: fields[4] as String?,
      note: fields[5] as String?,
      date: fields[6] as DateTime,
      paymentMode: fields[7] as String,
      isRecurring: fields[8] as bool,
      recurringFrequency: fields[9] as String?,
      recurringEndDate: fields[10] as DateTime?,
      createdAt: fields[11] as DateTime,
      merchantName: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.date)
      ..writeByte(7)
      ..write(obj.paymentMode)
      ..writeByte(8)
      ..write(obj.isRecurring)
      ..writeByte(9)
      ..write(obj.recurringFrequency)
      ..writeByte(10)
      ..write(obj.recurringEndDate)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.merchantName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 5;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.expense;
      case 1:
        return TransactionType.income;
      case 2:
        return TransactionType.savings;
      default:
        return TransactionType.expense;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.expense:
        writer.writeByte(0);
        break;
      case TransactionType.income:
        writer.writeByte(1);
        break;
      case TransactionType.savings:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentModeAdapter extends TypeAdapter<PaymentMode> {
  @override
  final int typeId = 6;

  @override
  PaymentMode read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentMode.cash;
      case 1:
        return PaymentMode.upi;
      case 2:
        return PaymentMode.card;
      case 3:
        return PaymentMode.bankTransfer;
      case 4:
        return PaymentMode.other;
      default:
        return PaymentMode.cash;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentMode obj) {
    switch (obj) {
      case PaymentMode.cash:
        writer.writeByte(0);
        break;
      case PaymentMode.upi:
        writer.writeByte(1);
        break;
      case PaymentMode.card:
        writer.writeByte(2);
        break;
      case PaymentMode.bankTransfer:
        writer.writeByte(3);
        break;
      case PaymentMode.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurringFrequencyAdapter extends TypeAdapter<RecurringFrequency> {
  @override
  final int typeId = 7;

  @override
  RecurringFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurringFrequency.daily;
      case 1:
        return RecurringFrequency.weekly;
      case 2:
        return RecurringFrequency.monthly;
      case 3:
        return RecurringFrequency.yearly;
      default:
        return RecurringFrequency.daily;
    }
  }

  @override
  void write(BinaryWriter writer, RecurringFrequency obj) {
    switch (obj) {
      case RecurringFrequency.daily:
        writer.writeByte(0);
        break;
      case RecurringFrequency.weekly:
        writer.writeByte(1);
        break;
      case RecurringFrequency.monthly:
        writer.writeByte(2);
        break;
      case RecurringFrequency.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
