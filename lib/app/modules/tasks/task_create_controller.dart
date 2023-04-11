import 'package:todo_list_provider/app/core/auth/auth_provider.dart';
import 'package:todo_list_provider/app/core/notifier/default_change_notifier.dart';
import 'package:todo_list_provider/app/services/tasks/tasks_service.dart';

class TaskCreateController extends DefaultChangeNotifier {
  final TasksService _tasksService;
  DateTime? _selectedDate;
  final AuthProvider _authProvider;

  TaskCreateController({
    required TasksService tasksService,
    required AuthProvider authProvider,
  })  : _tasksService = tasksService,
        _authProvider = authProvider;

  set selectedDate(DateTime? selectedDate) {
    resetState();
    _selectedDate = selectedDate;
    notifyListeners();
  }

  DateTime? get selectedDate => _selectedDate;

  void save(String description) async {
    try {
      showLoadingAndResetState();
      notifyListeners();
      if (_selectedDate != null) {
        if (_authProvider.user?.displayName!.isNotEmpty == true) {
          await _tasksService.save(_selectedDate!, description);
        } else {
          setError("Nome de usuário não cadastrado");
        }

        success();
      } else {
        setError("Data da task não selecionada");
      }
    } catch (e, s) {
      print(e);
      print(s);
      setError("Falta inserir seu nome ou apelido no perfil!!!");
    } finally {
      hideLoading();
      notifyListeners();
    }
  }
}
