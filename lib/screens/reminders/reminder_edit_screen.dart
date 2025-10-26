import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/reminder.dart';
import '../../data/mock_reminders.dart';
import '../../data/mock_pets.dart';
import '../../models/pet.dart';

/// SCR-REM-EDIT: Editar recordatorio existente
/// PROC-003: Recordatorios - FASE 2 Paso B
class ReminderEditScreen extends StatefulWidget {
  final Reminder reminder;

  const ReminderEditScreen({
    super.key,
    required this.reminder,
  });

  @override
  State<ReminderEditScreen> createState() => _ReminderEditScreenState();
}

class _ReminderEditScreenState extends State<ReminderEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late RepeatFrequency _repeatFrequency;
  late ReminderType _reminderType;
  late String _selectedPetId;
  bool _isSaving = false;
  bool _isDeleting = false;

  // Estado para mascotas disponibles
  List<Pet> _availablePets = [];
  bool _isLoadingPets = true;

  @override
  void initState() {
    super.initState();
    _initializeFromReminder();
    _loadPets();
  }

  /// Inicializar campos desde el recordatorio existente
  void _initializeFromReminder() {
    _titleController.text = widget.reminder.title;
    _notesController.text = widget.reminder.notes ?? '';

    // Parse fecha
    final reminderDate = DateTime.parse(widget.reminder.date);
    _selectedDate = reminderDate;

    // Parse hora
    final timeParts = widget.reminder.time.split(':');
    _selectedTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    _reminderType = widget.reminder.type;
    _repeatFrequency = widget.reminder.repeat;
    _selectedPetId = widget.reminder.petId;
  }

  /// Cargar mascotas disponibles desde el repositorio
  Future<void> _loadPets() async {
    final pets = await MockPetsRepository.getAllPets();
    setState(() {
      _availablePets = pets;
      _isLoadingPets = false;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _titleController.text.trim().isNotEmpty && !_isDeleting;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar recordatorio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cancelar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
            onPressed: _isDeleting || _isSaving ? null : _confirmDelete,
          ),
        ],
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
                    items: ReminderType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Row(
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
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
                              labelText: 'Fecha',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
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
                              labelText: 'Hora',
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
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
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
                              'Esta fecha/hora ya pasó',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 13,
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
                    items: RepeatFrequency.values.map((freq) {
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
                  if (_isLoadingPets)
                    const Center(child: CircularProgressIndicator())
                  else
                    DropdownButtonFormField<String>(
                      value: _selectedPetId,
                      decoration: const InputDecoration(
                        labelText: 'Mascota',
                        prefixIcon: Icon(Icons.pets),
                      ),
                      items: _availablePets.map((pet) {
                        return DropdownMenuItem(
                          value: pet.id,
                          child: Text(pet.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPetId = value);
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Selecciona una mascota' : null,
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

            // Botón actualizar sticky al fondo
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                        _isFormValid &&
                                !_isSaving &&
                                !_isLoadingPets &&
                                _availablePets.isNotEmpty
                            ? _updateReminder
                            : null,
                    icon:
                        _isSaving
                            ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Icon(Icons.save),
                    label: Text(
                      _isSaving ? 'Actualizando...' : 'Actualizar recordatorio',
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

  Future<void> _updateReminder() async {
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

    final updatedReminder = Reminder(
      id: widget.reminder.id, // Mantener ID original
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
      status: widget.reminder.status, // Mantener estado original
      type: _reminderType,
      createdAt: widget.reminder.createdAt, // Mantener fecha creación
      fromPlanId: widget.reminder.fromPlanId, // Mantener si existe
      taskId: widget.reminder.taskId, // Mantener si existe
      completedAt: widget.reminder.completedAt, // Mantener si existe
      snoozedUntil: widget.reminder.snoozedUntil, // Mantener si existe
    );

    try {
      final success = await MockRemindersRepository.updateReminder(
        widget.reminder.id,
        updatedReminder,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Recordatorio "${updatedReminder.title}" actualizado'),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Retornar true para indicar cambios
      } else {
        throw Exception('No se pudo actualizar el recordatorio');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// FASE 2 - Paso C: Confirmar eliminación
  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar recordatorio?'),
        content: Text(
          'Se eliminará "${widget.reminder.title}". Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteReminder();
    }
  }

  /// FASE 2 - Paso C: Eliminar recordatorio
  Future<void> _deleteReminder() async {
    setState(() => _isDeleting = true);

    try {
      final success = await MockRemindersRepository.deleteReminder(
        widget.reminder.id,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recordatorio "${widget.reminder.title}" eliminado'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true); // Indica que se eliminó
      } else {
        throw Exception('No se pudo eliminar');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isDeleting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
