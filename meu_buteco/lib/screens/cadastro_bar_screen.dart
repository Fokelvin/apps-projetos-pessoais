import 'package:flutter/material.dart';

class CadastroBar extends StatefulWidget {
  const CadastroBar({super.key});

  @override
  State<CadastroBar> createState() => _CadastroBarState();
}

final _formKey = GlobalKey<FormState>();
final nomeController = TextEditingController();
final endercoController = TextEditingController();

class _CadastroBarState extends State<CadastroBar> {
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
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Nome do Bar"
                ),
                validator: (value) =>
                  value == null || value.isEmpty ? "Informe o nome" : null,
              ),
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(
                  labelText: "Endereço do Bar"
                ),
                validator: (value) =>
                  value == null || value.isEmpty ? "Informe o endereço" : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: (){
                  if(_formKey.currentState!.validate()){

                  }
                }, 
                child: const Text("Salvar")
              )
            ],
          )
        ),
      ),
    );
  }
}