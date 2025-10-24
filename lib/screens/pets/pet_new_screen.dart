import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/pet.dart';
import '../../data/mock_pets.dart';

/// SCR-PET-NEW: Crear nueva mascota (PROC-001)
/// 
/// Formulario completo para registrar una mascota con:
/// - Campos obligatorios: nombre*, especie*
/// - Campos opcionales: raza, sexo, fecha nacimiento, peso, notas
/// - Validaciones inline según Pet.validarXXX()
/// - Botón guardar con loading state
/// 
/// Tokens de diseño aplicados:
/// - Tipografía: H1 (título), Label (campos), Body (inputs)
/// - Color: Primary (botón, focus), Error (validación)
/// - Espaciado: lg (24dp separación campos)
/// - Componentes: TextFormField, DropdownButtonFormField
class PetNewScreen extends StatefulWidget {
  const PetNewScreen({super.key});

  @override
  State<PetNewScreen> createState() => _PetNewScreenState();
}

class _PetNewScreenState extends State<PetNewScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para campos de texto
  final _nombreController = TextEditingController();
  final _razaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _notasController = TextEditingController();

  // Estado del formulario
  PetSpecies? _selectedEspecie;
  PetGender _selectedSexo = PetGender.noEspecifica;
  DateTime? _selectedFechaNacimiento;
  bool _isSaving = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _razaController.dispose();
    _pesoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  /// Validar si el formulario tiene datos mínimos obligatorios
  bool get _isFormValid {
    return _nombreController.text.trim().isNotEmpty && 
           _selectedEspecie != null;
  }

  /// Seleccionar fecha de nacimiento
  /// 
  /// Abre DatePicker nativo con rango válido (no futuro)
  Future<void> _selectFechaNacimiento() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedFechaNacimiento ?? DateTime.now(),
      firstDate: DateTime(1990), // Mascotas pueden tener hasta ~35 años
      lastDate: DateTime.now(), // No fechas futuras
      helpText: 'Selecciona fecha de nacimiento',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es'),
    );

    if (picked != null && picked != _selectedFechaNacimiento) {
      setState(() {
        _selectedFechaNacimiento = picked;
      });
    }
  }

  /// Guardar mascota en repositorio
  /// 
  /// Flujo:
  /// 1. Validar formulario
  /// 2. Crear objeto Pet con datos
  /// 3. Llamar a MockPetsRepository.createPet()
  /// 4. Regresar con true para recargar lista
  Future<void> _savePet() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validación adicional de campos obligatorios
    if (!_isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Completa los campos obligatorios (*)'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Parsear peso si existe
      double? peso;
      if (_pesoController.text.trim().isNotEmpty) {
        peso = double.tryParse(_pesoController.text.trim());
      }

      // Crear objeto Pet
      final newPet = Pet(
        id: '', // El repositorio generará el ID
        nombre: _nombreController.text.trim(),
        especie: _selectedEspecie!,
        raza: _razaController.text.trim().isEmpty 
            ? null 
            : _razaController.text.trim(),
        sexo: _selectedSexo,
        fechaNacimiento: _selectedFechaNacimiento,
        pesoKg: peso,
        notas: _notasController.text.trim().isEmpty 
            ? null 
            : _notasController.text.trim(),
      );

      // Guardar en repositorio
      await MockPetsRepository.createPet(newPet);

      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('${newPet.nombre} registrado exitosamente'),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Regresar con true para indicar que se creó una mascota
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text('Error al guardar: ${e.toString()}'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Construir campo de fecha de nacimiento
  /// 
  /// InputDecorator + InkWell para abrir DatePicker
  Widget _buildFechaNacimientoField() {
    return InkWell(
      onTap: _selectFechaNacimiento,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Fecha de nacimiento',
          hintText: 'Toca para seleccionar',
          prefixIcon: Icon(Icons.calendar_today),
          helperText: 'Opcional - Para calcular la edad',
        ),
        child: Text(
          _selectedFechaNacimiento != null
              ? DateFormat('dd/MM/yyyy', 'es').format(_selectedFechaNacimiento!)
              : 'No seleccionada',
          style: _selectedFechaNacimiento != null
              ? AppTypography.body
              : AppTypography.body.copyWith(color: AppColors.textDisabled),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar con botón cerrar
      appBar: AppBar(
        title: Text(
          'Nueva mascota',
          style: AppTypography.h1,
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cerrar sin guardar',
        ),
      ),
      backgroundColor: AppColors.background,
      
      body: Form(
        key: _formKey,
        onChanged: () => setState(() {}), // Actualizar estado para botón
        child: Column(
          children: [
            // Formulario scrolleable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // ========================================
                  // 1. NOMBRE * (Obligatorio)
                  // ========================================
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej. Luna',
                      prefixIcon: Icon(Icons.pets),
                      helperText: 'Obligatorio - 1 a 30 caracteres',
                    ),
                    textCapitalization: TextCapitalization.words,
                    autofocus: true,
                    maxLength: 30,
                    validator: Pet.validarNombre,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ========================================
                  // 2. ESPECIE * (Obligatorio)
                  // ========================================
                  DropdownButtonFormField<PetSpecies>(
                    value: _selectedEspecie,
                    decoration: const InputDecoration(
                      labelText: 'Especie *',
                      prefixIcon: Icon(Icons.category),
                      helperText: 'Obligatorio',
                    ),
                    hint: const Text('Selecciona una especie'),
                    items: PetSpecies.values.map((especie) {
                      return DropdownMenuItem(
                        value: especie,
                        child: Row(
                          children: [
                            Text(
                              especie.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(especie.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedEspecie = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'La especie es obligatoria';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ========================================
                  // 3. RAZA (Opcional)
                  // ========================================
                  TextFormField(
                    controller: _razaController,
                    decoration: const InputDecoration(
                      labelText: 'Raza',
                      hintText: 'Ej. Mestiza, Siamés, Golden',
                      prefixIcon: Icon(Icons.info_outline),
                      helperText: 'Opcional - Hasta 40 caracteres',
                    ),
                    textCapitalization: TextCapitalization.words,
                    maxLength: 40,
                    validator: Pet.validarRaza,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ========================================
                  // 4. SEXO (Opcional, default: No especifica)
                  // ========================================
                  DropdownButtonFormField<PetGender>(
                    value: _selectedSexo,
                    decoration: const InputDecoration(
                      labelText: 'Sexo',
                      prefixIcon: Icon(Icons.male),
                      helperText: 'Opcional',
                    ),
                    items: PetGender.values.map((sexo) {
                      return DropdownMenuItem(
                        value: sexo,
                        child: Row(
                          children: [
                            Text(
                              sexo.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(sexo.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedSexo = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ========================================
                  // 5. FECHA DE NACIMIENTO (Opcional)
                  // ========================================
                  _buildFechaNacimientoField(),
                  const SizedBox(height: AppSpacing.lg),

                  // ========================================
                  // 6. PESO (Opcional)
                  // ========================================
                  TextFormField(
                    controller: _pesoController,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      hintText: 'Ej. 15.5',
                      prefixIcon: Icon(Icons.monitor_weight),
                      helperText: 'Opcional - Entre 0.1 y 120 kg',
                      suffixText: 'kg',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: Pet.validarPeso,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ========================================
                  // 7. NOTAS (Opcional)
                  // ========================================
                  TextFormField(
                    controller: _notasController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      hintText: 'Información adicional sobre tu mascota...',
                      prefixIcon: Icon(Icons.notes),
                      helperText: 'Opcional - Hasta 200 caracteres',
                      alignLabelWithHint: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    maxLength: 200,
                    maxLines: 3,
                    validator: Pet.validarNotas,
                  ),
                  
                  // Espaciado final para que el último campo no quede pegado al botón
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),

            // ========================================
            // BOTÓN GUARDAR (siempre visible, deshabilitado si inválido)
            // ========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isSaving || !_isFormValid ? null : _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.textDisabled,
                  minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check, size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Guardar mascota',
                            style: AppTypography.button,
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
