import 'package:flutter/material.dart';
import 'package:flutter_overlay_loader/flutter_overlay_loader.dart';
import 'package:provider/provider.dart';
import 'package:todo_list_provider/app/core/auth/auth_provider.dart';
import 'package:todo_list_provider/app/core/ui/messages.dart';
import 'package:todo_list_provider/app/core/ui/theme_extensions.dart';
import 'package:todo_list_provider/app/services/user/user_service.dart';

class HomeDrawer extends StatelessWidget {
  final nameVN = ValueNotifier<String>("");

  HomeDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: context.primaryColor.withAlpha(70),
            ),
            child: Row(
              children: [
                Selector<AuthProvider, String>(
                  selector: (context, authProvider) {
                    return authProvider.user?.photoURL ??
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRdRkONn64ma6rtrr63sJioN0oji0bbuwbj0A&usqp=CAU";
                  },
                  builder: (_, value, __) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(value),
                      radius: 30,
                    );
                  },
                ),
                Expanded(
                  child: Selector<AuthProvider, String>(
                    selector: (context, authProvider) {
                      return authProvider.user?.displayName ?? "Não informado";
                    },
                    builder: (_, value, __) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          value,
                          style: context.textTheme.subtitle2,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            title: const Text("Alterar nome"),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (_) {
                    return AlertDialog(
                      title: const Text("Alterar nome"),
                      content: TextField(
                        onChanged: (value) => nameVN.value = value,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            final nameValue = nameVN.value;
                            if (nameValue.isEmpty) {
                              Messages.of(context)
                                  .showError("Nome obrigatório");
                            } else {
                              Loader.show(context);
                              await context
                                  .read<UserService>()
                                  .updateDisplayName(nameValue);
                              Loader.hide();
                              // ignore: use_build_context_synchronously
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text("Alterar"),
                        ),
                      ],
                    );
                  });
            },
          ),
          ListTile(
            onTap: () => context.read<AuthProvider>().logout(),
            title: const Text("Sair"),
          ),
        ],
      ),
    );
  }
}
