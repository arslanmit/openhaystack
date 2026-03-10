import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openhaystack_mobile/accessory/accessory_model.dart';

void main() {
  test('serializes and deserializes accessory metadata without changing color',
      () {
    final accessory = Accessory(
      id: 'demo-id',
      name: 'Backpack',
      hashedPublicKey: 'hashed-public-key',
      datePublished: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      color: const Color(0xff123456),
      icon: 'case.fill',
      isActive: true,
      isDeployed: true,
      usesDerivation: true,
      symmetricKey: 'sym-key',
      lastDerivationTimestamp: 1234.5,
      updateInterval: 900,
      oldestRelevantSymmetricKey: 'old-sym-key',
    );

    final serialized = accessory.toJson();
    final restored = Accessory.fromJson(serialized);

    expect(serialized['color'], 'ff123456');
    expect(restored.id, accessory.id);
    expect(restored.name, accessory.name);
    expect(restored.hashedPublicKey, accessory.hashedPublicKey);
    expect(
      restored.datePublished?.millisecondsSinceEpoch,
      accessory.datePublished?.millisecondsSinceEpoch,
    );
    expect(restored.rawIcon, accessory.rawIcon);
    expect(restored.color.toARGB32(), accessory.color.toARGB32());
    expect(restored.isActive, accessory.isActive);
    expect(restored.isDeployed, accessory.isDeployed);
    expect(restored.usesDerivation, accessory.usesDerivation);
    expect(restored.symmetricKey, accessory.symmetricKey);
    expect(
      restored.lastDerivationTimestamp,
      accessory.lastDerivationTimestamp,
    );
    expect(restored.updateInterval, accessory.updateInterval);
    expect(
      restored.oldestRelevantSymmetricKey,
      accessory.oldestRelevantSymmetricKey,
    );
  });
}
