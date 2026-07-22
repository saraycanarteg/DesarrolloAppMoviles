import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/contacto.dart';
import '../../domain/repositories/contacto_repository.dart';
import '../../data/repositories/contacto_repository_impl.dart';
import '../../data/datasources/contacto_local_datasource.dart';
import '../../application/usecases/contacto_usecases.dart';

final databaseProvider = Provider<Database> ((ref) {
  throw UnimplementedError('La base de datos inicia desde main');
});

final contactoLocalDatasourceProvider = Provider<ContactoLocalDatasource> ((ref){
  final database = ref.watch(databaseProvider);
  return ContactoLocalDatasource(database);
});

//no se trabaja directamente con SQLIte, sino que aqui se crea un repository
// y se dice que aqui se usara darasource para guardar datos en la base de datos
// SQLITE-DATABASE-REPOSITORY
final contactoRepositoryProvider = Provider<ContactoRepository> ((ref){
  final dataSource = ref.watch(contactoLocalDatasourceProvider);
  return ContactoRepositoryImpl(dataSource);
});

//Se crean los casos de uso (agregar contacto, editar, etc)
final contactoUseCasesProvider = Provider<ContactoUsecases> ((ref){
  final repository = ref.watch(contactoRepositoryProvider);
  return ContactoUsecases(repository);
});

//*********************************************************
//                       Crear clases
//*********************************************************

//manejar el estado de la pantalla - view model
// cargguen contactos, agregue, actualice
class ContactoNotifier extends StateNotifier<List<Contacto>> {
  //instanciar a contactoUsecase
  final ContactoUsecases contactoUsecases;

  ContactoNotifier(this.contactoUsecases) : super([]){
    cargarContactos();
  }

  //metodo para cargar contactos
  Future <void> cargarContactos() async{
    state = await contactoUsecases.listar();
  }

  Future <void> agregarContactos(
      String nombre,
      String telefono,
      String correo
      ) async{
    final contacto = Contacto(
      nombre: nombre,
      telefono: telefono,
      correo: correo, id: null,
    );
    //irse a sqlite
    await contactoUsecases.agregarContacto(contacto);
    //select
    await cargarContactos();
  }

  Future <void> actualizarContactos(
      int id,
      String nombre,
      String telefono,
      String correo
      ) async{
    final contacto = Contacto(
      id: id,
      nombre: nombre,
      telefono: telefono,
      correo: correo,
    );
    //irse a sqlite
    await contactoUsecases.actualizarContacto(contacto);
    //select
    await cargarContactos();
  }

  Future <void> eliminarContactos(int id) async{
    await contactoUsecases.eliminarContacto(id);
    await cargarContactos();
  }
}

//rivepod para manejar contacto notifier
final contactoProvider = StateNotifierProvider<ContactoNotifier, List<Contacto>> ((ref){
  final useCases = ref.watch(contactoUseCasesProvider);
  return ContactoNotifier(useCases);
});