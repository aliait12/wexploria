import 'package:flutter/material.dart';
import 'package:wexploria_app/core/constants/app_constants.dart';
import 'package:wexploria_app/core/models/activite.dart';
import 'package:wexploria_app/core/services/activite_service.dart';
import 'package:wexploria_app/features/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActiviteForm extends StatefulWidget {
  final Activite? activite;
  final VoidCallback? onSaved;

  const ActiviteForm({super.key, this.activite, this.onSaved});

  @override
  State<ActiviteForm> createState() => _ActiviteFormState();
}

class _ActiviteFormState extends State<ActiviteForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = ActiviteService();
  final _authService = AuthService();

  final _titreController = TextEditingController();
  final _descController = TextEditingController();
  final _prixController = TextEditingController();
  final _dureeController = TextEditingController();
  final _capaciteController = TextEditingController();
  final _localisationController = TextEditingController();

  String _typeActivite = 'parapente';
  String _niveauDifficulte = 'debutant';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.activite != null) {
      _titreController.text = widget.activite!.titre;
      _descController.text = widget.activite!.description ?? '';
      _prixController.text = widget.activite!.prixBase.toString();
      _dureeController.text = widget.activite!.dureeEstimee.toString();
      _capaciteController.text = widget.activite!.capaciteMax.toString();
      _localisationController.text = widget.activite!.localisationPrecise;
      _typeActivite = widget.activite!.typeActivite;
      _niveauDifficulte = widget.activite!.niveauDifficulte;
    }
  }

  @override
  void dispose() {
    _titreController.dispose();
    _descController.dispose();
    _prixController.dispose();
    _dureeController.dispose();
    _capaciteController.dispose();
    _localisationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      String operateurId = user.id;

      try {
        final operatorData = await Supabase.instance.client
            .from('operateurs')
            .select('id')
            .eq('user_id', user.id)
            .maybeSingle();

        if (operatorData != null) {
          operateurId = operatorData['id'] as String;
        } else {
          try {
            final newOp = await Supabase.instance.client
                .from('operateurs')
                .insert({
                  'user_id': user.id,
                  'nom': 'Nouveau Opérateur',
                  'contact_email': user.email,
                })
                .select('id')
                .single();
            operateurId = newOp['id'] as String;
          } catch (_) {
            throw Exception(
              "Vous n'êtes pas enregistré comme opérateur. Contactez le support.",
            );
          }
        }
      } catch (e) {
        debugPrint('Warning fetching operator ID: $e');
      }

      final activiteData = {
        'titre': _titreController.text,
        'description': _descController.text,
        'type_activite': _typeActivite,
        'niveau_difficulte': _niveauDifficulte,
        'prix_base': double.parse(_prixController.text),
        'duree_estimee': int.parse(_dureeController.text),
        'capacite_max': int.parse(_capaciteController.text),
        'localisation_precise': _localisationController.text,
        'operateur_id': operateurId,
        'statut': 'actif',
      };

      if (widget.activite == null) {
        await _service.createActivite(activiteData);
      } else {
        await _service.updateActivite(widget.activite!.id, activiteData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.activite == null
                  ? 'Activité créée !'
                  : 'Activité mise à jour !',
            ),
          ),
        );
        Navigator.pop(context);
        widget.onSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.activite == null
              ? 'Nouvelle Activité'
              : 'Modifier l\'Activité',
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titreController,
                      decoration: const InputDecoration(labelText: 'Titre'),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _typeActivite,
                      decoration: const InputDecoration(
                        labelText: 'Type d\'activité',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'parapente',
                          child: Text('Parapente'),
                        ),
                        DropdownMenuItem(value: 'surf', child: Text('Surf')),
                        DropdownMenuItem(
                          value: 'kitesurf',
                          child: Text('Kitesurf'),
                        ),
                        DropdownMenuItem(value: 'quad', child: Text('Quad')),
                        DropdownMenuItem(
                          value: 'trekking',
                          child: Text('Trekking'),
                        ),
                        DropdownMenuItem(
                          value: 'hot_air_balloon',
                          child: Text('Montgolfière'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _typeActivite = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      value: _niveauDifficulte,
                      decoration: const InputDecoration(labelText: 'Niveau'),
                      items: const [
                        DropdownMenuItem(
                          value: 'debutant',
                          child: Text('Débutant'),
                        ),
                        DropdownMenuItem(
                          value: 'intermediaire',
                          child: Text('Intermédiaire'),
                        ),
                        DropdownMenuItem(
                          value: 'expert',
                          child: Text('Expert'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _niveauDifficulte = v!),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _prixController,
                            decoration: const InputDecoration(
                              labelText: 'Prix (€)',
                              suffixText: '€',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: TextFormField(
                            controller: _dureeController,
                            decoration: const InputDecoration(
                              labelText: 'Durée (min)',
                              suffixText: 'min',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Requis' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _capaciteController,
                      decoration: const InputDecoration(
                        labelText: 'Capacité Max',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _localisationController,
                      decoration: const InputDecoration(
                        labelText: 'Localisation',
                      ),
                      validator: (v) => v!.isEmpty ? 'Requis' : null,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textWhite,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                        ),
                        child: Text(
                          widget.activite == null ? 'CRÉER' : 'ENREGISTRER',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
