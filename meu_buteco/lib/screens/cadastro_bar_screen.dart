import 'package:flutter/material.dart';
import 'package:meu_buteco/models/bar_model.dart';

class CadastroBar extends StatefulWidget {
  const CadastroBar({super.key});

  @override
  State<CadastroBar> createState() => _CadastroBarState();
}

class _CadastroBarState extends State<CadastroBar> {

  final _formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final endercoController = TextEditingController();
  final linkController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cadastrar novo Bar"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                
                //Campo 1
                TextFormField(
                  controller: nomeController,
                  decoration: const InputDecoration(
                    labelText: "Nome do Bar"
                  ),
                  validator: (value) =>
                    value == null || value.isEmpty ? "Informe o nome" : null,
                ),

                const SizedBox(height: 24),
                
                //Campo 2
                TextFormField(
                  controller: endercoController,
                  decoration: const InputDecoration(
                    labelText: "Endereço do Bar"
                  ),
                  validator: (value) =>
                    value == null || value.isEmpty ? "Informe o endereço" : null,
                ),

                const SizedBox(height: 24),

                //Campo3
                  TextFormField(
                  controller: linkController,
                  decoration: const InputDecoration(
                    labelText: "Link imagem"
                  ),
                  validator: (value) =>
                    value == null || value.isEmpty ? "informe o link" : null,
                ),
                
                const SizedBox(height: 24),

                //Botao
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () async{
                    if(_formKey.currentState!.validate()){
                      print('Botão pressionado');
                      final bar = BarModel(
                        nomeController.text, 
                        endercoController.text, 
                        linkController.text
                      );
                      print('Dados bar: $bar');
                      await bar.salvarNoFirebase();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Novo bar salvo com sucesso")),
                      );
                    }
                  }, 
                  child: const Text("Salvar")
                )
              ],
            )
          ),
        ),
      ),
    );
  }
}