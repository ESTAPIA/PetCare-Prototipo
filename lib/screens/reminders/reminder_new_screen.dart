import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/reminder.dart';
import '../../data/mock_reminders.dart';

/// SCR-REM-NEW: Crear nuevo recordatorio
/// PROC-003: Recordatorios
class ReminderNewScreen extends StatefulWidget {
  final String? sourceContext; // 'chat' si viene desde consulta
  final ReminderType? initialType; // Tipo pre-seleccionado desde chat

  const ReminderNewScreen({
    super.key,
    this.sourceContext,
    this.initialType,
  });

  @override
  State<ReminderNewScreen> createState() => _ReminderNewScreenState();
}

class _ReminderNewScreenState extends State<ReminderNewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  RepeatFrequency _repeatFrequency = RepeatFrequency.none;
  late ReminderType _reminderType;
  String _selectedPetId = 'pet-001'; // Mock: Luna
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar tipo desde parámetro o usar valor por defecto
    _reminderType = widget.initialType ?? ReminderType.other;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cancelar',
        ),
      ),
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Título
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Ej. Vacuna anual',
                      prefixIcon: Icon(Icons.title),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es obligatorio';
                      }
                      if (value.length > 100) {
                        return 'Máximo 100 caracteres';
                      }
                      return null;
                    },
                    maxLength: 100,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Tipo de recordatorio
                  DropdownButtonFormField<ReminderType>(
                    value: _reminderType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items:
                        ReminderType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              children: [
                                Text(
                                  type.emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                const SizedBox(width: 8),
                                Text(type.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _reminderType = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Fecha y hora
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Fecha *',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat(
                                'dd/MM/yyyy',
                                'es',
                              ).format(_selectedDate),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: InkWell(
                          onTap: _selectTime,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Hora *',
                              prefixIcon: Icon(Icons.access_time),
                            ),
                            child: Text(_selectedTime.format(context)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Warning si fecha pasada
                  if (_isDateInPast()) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        border: Border.all(color: AppColors.warning),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Esta fecha ya pasó. El recordatorio aparecerá como vencido.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),

                  // Frecuencia de repetición
                  DropdownButtonFormField<RepeatFrequency>(
                    value: _repeatFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Repetir',
                      prefixIcon: Icon(Icons.repeat),
                    ),
                    items:
                        RepeatFrequency.values.map((freq) {
                          return DropdownMenuItem(
                            value: freq,
                            child: Text(freq.displayName),
                          );
                        }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _repeatFrequency = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Mascota asignada
                  DropdownButtonFormField<String>(
                    value: _selectedPetId,
                    decoration: const InputDecoration(
                      labelText: 'Para qué mascota *',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'pet-001',
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              child: Icon(Icons.pets, size: 12),
                            ),
                            SizedBox(width: 8),
                            Text('Luna (Perra)'),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'pet-002',
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              child: Icon(Icons.pets, size: 12),
                            ),
                            SizedBox(width: 8),
                            Text('Max (Gato)'),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedPetId = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Notas (opcional)
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notas (opcional)',
                      hintText: 'Detalles adicionales...',
                      prefixIcon: Icon(Icons.notes),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    maxLength: 500,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),

            // Botón guardar sticky al fondo
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        _isFormValid && !_isSaving ? _saveReminder : null,
                    icon:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Guardando...' : 'Guardar recordatorio',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isDateInPast() {
    final selectedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    return selectedDateTime.isBefore(DateTime.now());
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('es', 'ES'),
      helpText: 'Seleccionar fecha',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      helpText: 'Seleccionar hora',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Por favor completa todos los campos obligatorios',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final newReminder = Reminder(
      id: 'rem-${DateTime.now().millisecondsSinceEpoch}',
      petId: _selectedPetId,
      title: _titleController.text.trim(),
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      time:
          '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
      repeat: _repeatFrequency,
      notes:
          _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
      status: ReminderStatus.pending,
      type: _reminderType,
    );

    try {
      final success = await MockRemindersRepository.createReminder(newReminder);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Recordatorio "${newReminder.title}" creado'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('No se pudo guardar el recordatorio');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
