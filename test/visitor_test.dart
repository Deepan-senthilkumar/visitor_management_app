import 'package:flutter_test/flutter_test.dart';
import 'package:visitor_management_app/models/visitor.dart';
import 'package:visitor_management_app/providers/visitor_provider.dart';

void main() {
  group('Visitor Model Tests', () {
    test('Visitor.fromJson parses data correctly', () {
      final json = {
        'id': '101',
        'name': 'Rahul Sharma',
        'mobile': '9876543210',
        'email': 'rahul@example.com',
        'visitorType': 'Customer',
        'project': 'Project A',
        'purpose': 'Site Visit',
        'status': 'Registered',
        'createdAt': '2026-10-28T10:00:00.000Z',
      };

      final visitor = Visitor.fromJson(json);

      expect(visitor.id, '101');
      expect(visitor.name, 'Rahul Sharma');
      expect(visitor.mobile, '9876543210');
      expect(visitor.visitorType, 'Customer');
      expect(visitor.status, 'Registered');
    });

    test('Visitor.copyWith updates specified fields', () {
      final visitor = Visitor(
        id: '1',
        name: 'John Doe',
        mobile: '1234567890',
        visitorType: 'Vendor',
        project: 'Project B',
        status: 'Registered',
        purpose: 'Delivery',
        createdAt: '2026-10-28T10:00:00.000Z',
      );

      final updated = visitor.copyWith(
        status: 'Checked In',
        checkInTime: '2026-10-28T10:30:00.000Z',
      );

      expect(updated.status, 'Checked In');
      expect(updated.checkInTime, '2026-10-28T10:30:00.000Z');
      expect(updated.name, 'John Doe');
    });

    test('VisitorStatus.fromString resolves case-insensitively', () {
      expect(VisitorStatus.fromString('registered'), VisitorStatus.registered);
      expect(VisitorStatus.fromString('Checked In'), VisitorStatus.checkedIn);
      expect(VisitorStatus.fromString('Unknown'), VisitorStatus.registered);
    });
  });

  group('Provider Business Rule Tests', () {
    test('checkIn throws if visitor is already Checked In', () async {
      final provider = VisitorProvider();
      final alreadyCheckedIn = Visitor(
        id: '1',
        name: 'Test',
        mobile: '1234567890',
        visitorType: 'Customer',
        project: 'Project A',
        status: 'Checked In',
        purpose: 'Meeting',
        createdAt: '2026-10-28T10:00:00.000Z',
      );

      expect(
        () => provider.checkIn(alreadyCheckedIn),
        throwsA(isA<Exception>()),
      );
    });

    test('checkOut throws if visitor is not Checked In', () async {
      final provider = VisitorProvider();
      final registered = Visitor(
        id: '1',
        name: 'Test',
        mobile: '1234567890',
        visitorType: 'Customer',
        project: 'Project A',
        status: 'Registered',
        purpose: 'Meeting',
        createdAt: '2026-10-28T10:00:00.000Z',
      );

      expect(
        () => provider.checkOut(registered),
        throwsA(isA<Exception>()),
      );
    });
  });
}
