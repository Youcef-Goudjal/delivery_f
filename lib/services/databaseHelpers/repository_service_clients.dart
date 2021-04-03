import 'package:delivery_f/models/client.dart';

import '../database_creator.dart';

class RepositoryServiceClients {
  //get All Clients
  static Future<List<Client>> getAllClients() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.client_tbl}
    WHERE 1 ''';
    final data = await db.rawQuery(sql);
    List<Client> clients = List();
    for (final node in data) {
      final client = Client.fromJson(node);
      clients.add(client);
    }
    return clients;
  }

  // add new Client
  static Future<int> addClient(Client client) async {
    final sql = '''INSERT INTO ${DatabaseCreator.client_tbl}
    (
      ${DatabaseCreator.client_fullName},
      ${DatabaseCreator.client_phone},
      ${DatabaseCreator.client_credit}
    )
    VALUES (?,?,?)''';
    List<dynamic> params = [
      client.fullname,
      client.phone.toString(),
      client.credits.toString(),
    ];
    final result = await db.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add client', sql, null, result, params);
    return result;
  }

  // updating client
  static Future<int> updateClient(Client client) async {
    final sql = '''UPDATE ${DatabaseCreator.client_tbl}
      SET ${DatabaseCreator.client_fullName}  = ? ,
          ${DatabaseCreator.client_phone}     = ? ,
          ${DatabaseCreator.client_credit}    = ? 
      WHERE  ${DatabaseCreator.client_id}     = ?
    
    ''';
    List<dynamic> params = [
      client.fullname,
      client.phone.toString(),
      client.credits.toString(),
      client.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update client', sql, null, result, params);
    return result;
  }

  // updating client
  static Future<int> updateClientCredit(Client client) async {
    final sql = '''UPDATE ${DatabaseCreator.client_tbl}
      SET 
          ${DatabaseCreator.client_credit}    = ? 
      WHERE  ${DatabaseCreator.client_id}     = ?
    
    ''';
    List<dynamic> params = [
      client.credits.toString(),
      client.id,
    ];

    final result = await db.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update client', sql, null, result, params);
    return result;
  }

  // search for clients
  static Future<List<Client>> search(String input) async {
    String phone = (input != "") ? input.substring(1) : "";
    print(phone);

    final sql = '''SELECT * FROM ${DatabaseCreator.client_tbl}
    WHERE ${DatabaseCreator.client_fullName} LIKE '%$input%' OR ${DatabaseCreator.client_phone} LIKE '%$phone%'  ''';
    final data = await db.rawQuery(sql);
    List<Client> clients = [];

    for (final node in data) {
      final client = Client.fromJson(node);
      clients.add(client);
    }

    return clients;
  }

  static Future<int> deleteClient(int id) async {
    /*String sql = ''' DELETE FROM ${DatabaseCreator.client_tbl}
                    WHERE ${DatabaseCreator.client_id} = $id ;  ''';
    return await db.rawDelete(sql);*/
    return 1;
  }
}
