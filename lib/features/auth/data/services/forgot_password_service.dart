import 'dart:math';
import 'package:postgres/postgres.dart';
import 'package:tokona/core/database/app_database.dart';
import 'package:tokona/core/database/database_tables.dart';
import 'package:tokona/core/utils/id_generator.dart';
import 'package:tokona/features/auth/domain/models/user_model.dart';

class ForgotPasswordService {
  ForgotPasswordService._();

  static const String poolerHost = 'aws-0-ap-south-1.pooler.supabase.com';
  static const String poolerUsername = 'postgres.gjgfdwzqjypzalzleqgt';
  static const String directHost = 'db.gjgfdwzqjypzalzleqgt.supabase.co';
  static const String directUsername = 'postgres';
  static const String database = 'postgres';
  static const String password = 'siffpdzueridtaquvpml';

  static Future<Connection> _connect() async {
    Object? lastErr;
    try {
      return await Connection.open(
        Endpoint(
          host: poolerHost,
          port: 5432,
          database: database,
          username: poolerUsername,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 8),
        ),
      );
    } catch (e) {
      lastErr = e;
    }

    try {
      return await Connection.open(
        Endpoint(
          host: directHost,
          port: 5432,
          database: database,
          username: directUsername,
          password: password,
        ),
        settings: const ConnectionSettings(
          sslMode: SslMode.require,
          connectTimeout: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      throw StateError('Koneksi Cloud Supabase gagal: $lastErr');
    }
  }

  static Future<void> _ensureSchema(Connection conn) async {
    await conn.execute('''
      CREATE TABLE IF NOT EXISTS tokona_password_resets (
        id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        email_or_phone TEXT NOT NULL,
        otp_code TEXT NOT NULL,
        expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
        is_used BOOLEAN NOT NULL DEFAULT FALSE,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      )
    ''');
    try {
      await conn.execute('''
        CREATE INDEX IF NOT EXISTS idx_tokona_pw_resets_user 
        ON tokona_password_resets(username, otp_code)
      ''');
    } catch (_) {}
  }

  static Future<String> generateAndSendOtp({
    required String username,
    required String emailOrPhone,
  }) async {
    final rand = Random();
    final otp = (100000 + rand.nextInt(900000)).toString();
    final resetId = IdGenerator.generateId(prefix: 'RST');
    final expiresAt = DateTime.now().add(const Duration(minutes: 10));

    try {
      final conn = await _connect();
      try {
        await _ensureSchema(conn);
        await conn.execute(
          Sql.named('''
            INSERT INTO tokona_password_resets (id, username, email_or_phone, otp_code, expires_at, is_used, created_at)
            VALUES (@id, @username, @email_or_phone, @otp_code, @expires_at, FALSE, NOW())
          '''),
          parameters: {
            'id': resetId,
            'username': username.trim().toLowerCase(),
            'email_or_phone': emailOrPhone.trim(),
            'otp_code': otp,
            'expires_at': expiresAt,
          },
        );
      } finally {
        await conn.close();
      }
    } catch (_) {
      // Jika jaringan cloud terkendala, tetap izinkan kode OTP lokal berjalan
    }

    return otp;
  }

  static Future<bool> verifyOtp({
    required String username,
    required String otpCode,
    String? expectedFallbackOtp,
  }) async {
    final cleanOtp = otpCode.trim();
    if (expectedFallbackOtp != null && cleanOtp == expectedFallbackOtp) {
      return true;
    }

    try {
      final conn = await _connect();
      try {
        await _ensureSchema(conn);
        final res = await conn.execute(
          Sql.named('''
            SELECT id FROM tokona_password_resets
            WHERE LOWER(username) = LOWER(@username)
              AND otp_code = @otp_code
              AND is_used = FALSE
              AND expires_at > NOW()
            ORDER BY created_at DESC
            LIMIT 1
          '''),
          parameters: {
            'username': username.trim().toLowerCase(),
            'otp_code': cleanOtp,
          },
        );

        if (res.isNotEmpty) {
          final id = res.first[0] as String;
          await conn.execute(
            Sql.named('UPDATE tokona_password_resets SET is_used = TRUE WHERE id = @id'),
            parameters: {'id': id},
          );
          return true;
        }
      } finally {
        await conn.close();
      }
    } catch (_) {}

    return false;
  }

  static Future<({bool exists, bool isLocal, String? phone, String? roleLabel, UserModel? user})> checkUserLocation(String username) async {
    final cleanUser = username.trim().toLowerCase();
    try {
      final db = await AppDatabase.instance.database;
      final localRes = await db.query(
        DatabaseTables.users,
        where: 'LOWER(username) = ?',
        whereArgs: [cleanUser],
        limit: 1,
      );
      if (localRes.isNotEmpty) {
        final localUser = UserModel.fromMap(localRes.first);
        String? phone;
        final storeRes = await db.query(DatabaseTables.stores, where: 'id = ?', whereArgs: [localUser.storeId], limit: 1);
        if (storeRes.isNotEmpty) {
          phone = storeRes.first[DatabaseTables.columnStorePhone] as String?;
        }
        return (exists: true, isLocal: true, phone: phone, roleLabel: localUser.role.label, user: localUser);
      }
    } catch (_) {}

    try {
      final conn = await _connect();
      try {
        final res = await conn.execute(
          Sql.named('SELECT id, store_id, username, full_name, role FROM tokona_users WHERE LOWER(username) = @u LIMIT 1'),
          parameters: {'u': cleanUser},
        );
        if (res.isNotEmpty) {
          return (exists: true, isLocal: false, phone: null, roleLabel: res.first[4]?.toString() ?? 'Staf Cloud', user: null);
        }
      } finally {
        await conn.close();
      }
    } catch (_) {}

    return (exists: false, isLocal: false, phone: null, roleLabel: null, user: null);
  }

  static Future<String?> getOwnerPhone() async {
    try {
      final db = await AppDatabase.instance.database;
      final stores = await db.query(DatabaseTables.stores, limit: 1);
      if (stores.isNotEmpty) {
        return stores.first[DatabaseTables.columnStorePhone] as String?;
      }
    } catch (_) {}
    return null;
  }
}
