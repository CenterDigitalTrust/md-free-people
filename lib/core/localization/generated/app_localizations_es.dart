import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsGeneratedEs extends AppLocalizationsGenerated {
  AppLocalizationsGeneratedEs([String locale = 'es']) : super(locale);

  @override
  String get app_title => 'MD Free People';

  @override
  String get tagline => 'Registra. Confirma. Entrega.';

  @override
  String get card1_title => 'Captura solo en la aplicación';

  @override
  String get card1_desc => 'La importación desde la galería está deshabilitada. Grabe en la aplicación para crear una huella firmada del archivo.';

  @override
  String get card2_title => 'Lo que la aplicación no hace';

  @override
  String get card2_desc => 'No evalúa el contenido de los sucesos, no verifica la identidad personal ni valida las circunstancias.';

  @override
  String get card3_title => 'Firma en el dispositivo, huella en la cadena de bloques';

  @override
  String get card3_desc => 'Android guarda la clave privada en Keystore. La protección por hardware depende del dispositivo; la atestación no está confirmada.';

  @override
  String get btn_continue => 'Continuar';

  @override
  String get disclaimer => 'Confirma que el archivo no ha sido modificado desde su registro. No evalúa el contenido del suceso.';

  @override
  String get geo_note => 'Ubicación: según los datos del dispositivo.';

  @override
  String recorded_by(String time) {
    return 'Registrado a más tardar el: $time';
  }

  @override
  String verify_ok(String time) {
    return 'El archivo coincide con el registrado. Sin cambios desde $time.';
  }

  @override
  String get verify_fail => 'El archivo difiere del registrado.';

  @override
  String get testnet_note => '(red de pruebas)';

  @override
  String get nav_capture => 'Captura';

  @override
  String get nav_records => 'Mis registros';

  @override
  String get nav_verify => 'Verificación';

  @override
  String get nav_settings => 'Ajustes';

  @override
  String get mode_photo => 'Foto';

  @override
  String get mode_video => 'Video';

  @override
  String get mode_audio => 'Audio';

  @override
  String get capture_footer_note => 'Grabado en la aplicación. La selección desde la galería está deshabilitada.';

  @override
  String get no_connection_note => 'sin conexión: guardando en el teléfono';

  @override
  String get status_on_device => 'En el teléfono';

  @override
  String get status_queued => 'Enviado';

  @override
  String get status_anchored => 'Confirmado';

  @override
  String get status_simulated => 'Registro de prueba';

  @override
  String get file_upload_policy => 'Envío de archivos';

  @override
  String get file_upload_manual => 'Manual';

  @override
  String get file_upload_wifi => 'Solo con Wi-Fi';

  @override
  String get file_upload_desc => 'El resumen se envía siempre; el archivo multimedia va al almacenamiento independiente solo si usted lo permite.';

  @override
  String get record_detail_title => 'Detalle del registro';

  @override
  String get device_attestation_title => 'Dispositivo';

  @override
  String get attestation_not_verified => 'atestación no confirmada';

  @override
  String get btn_share_cert => 'Compartir certificado (PDF)';

  @override
  String get btn_share_receipt => 'Compartir recibo (.mdfp.json)';

  @override
  String get btn_send_file_vault => 'Enviar archivo al servidor independiente';

  @override
  String get btn_select_file => 'Elegir archivo';

  @override
  String get btn_scan_qr => 'Escanear QR';

  @override
  String get tech_info_title => 'Mostrar información técnica';

  @override
  String get settings_language => 'Idioma de la aplicación';

  @override
  String get btn_purge_data => 'Eliminar datos en el teléfono';

  @override
  String get purge_confirm_desc => 'Se eliminarán definitivamente los archivos locales, incluidos los pendientes de envío. Las copias del servidor no se eliminan. Solana Devnet es una red de pruebas y sus registros pueden reiniciarse.';

  @override
  String get app_version => 'Versión de la aplicación';

  @override
  String get perm_camera => 'Cámara: para capturar pruebas dentro de la aplicación.';

  @override
  String get perm_mic => 'Micrófono: para la grabación de video y audio de sucesos.';

  @override
  String get perm_location => 'Ubicación: registro de coordenadas del dispositivo (opcional).';

  @override
  String get file_unchanged_header => 'ARCHIVO NO MODIFICADO';

  @override
  String get finish_recording => 'Primero finalice la grabación.';

  @override
  String get settings_error => 'No se pudieron guardar los ajustes. Inténtelo de nuevo.';

  @override
  String get storage_error => 'No se pudieron leer los registros guardados. Inténtelo de nuevo.';

  @override
  String get camera_permission => 'Permita el acceso a la cámara en los ajustes de Android.';

  @override
  String get microphone_permission => 'Permita el acceso al micrófono en los ajustes de Android.';

  @override
  String get camera_unavailable => 'La cámara no está disponible. Intente reconectarla.';

  @override
  String get audio_not_saved => 'No se pudo guardar la grabación de audio.';

  @override
  String get capture_error => 'No se pudo grabar o guardar el archivo. Revise los permisos y el espacio disponible e inténtelo de nuevo.';

  @override
  String get device_registration_required => 'Se necesita internet para registrar el dispositivo por primera vez. Inténtelo de nuevo.';

  @override
  String get capture_saved => 'Grabación guardada y firmada. Consulte el estado de envío en Mis registros.';

  @override
  String get capture_network_note => 'Solana Devnet • GPS incluido si está disponible';

  @override
  String get connect_camera => 'Conectar dispositivo y cámara';

  @override
  String get start_capture => 'Capturar / iniciar grabación';

  @override
  String get stop_capture => 'Detener grabación';

  @override
  String get refresh => 'Actualizar';

  @override
  String get records_empty => 'Aún no hay registros';

  @override
  String get status_failed => 'Pendiente de reintento';

  @override
  String get status_unknown => 'Estado desconocido';

  @override
  String get vault_pending => 'Pendiente de envío';

  @override
  String get vault_uploaded => 'Enviado';

  @override
  String get status_label => 'Estado';

  @override
  String bytes(String count) {
    return '$count bytes';
  }

  @override
  String get file_label => 'Archivo';

  @override
  String get signature_label => 'Firma';

  @override
  String get size_label => 'Tamaño';

  @override
  String get gps_missing => 'GPS: no disponible';

  @override
  String gps_coordinates(String lat, String lon, String accuracy) {
    return 'GPS: $lat, $lon ±$accuracy m';
  }

  @override
  String get unknown => 'Desconocido';

  @override
  String get block_time => 'Hora del bloque';

  @override
  String get public_digest => 'Resumen público del registro (para verificar su inclusión):';

  @override
  String get copy_digest => 'Copiar resumen';

  @override
  String get copy_success => 'Copiado al portapapeles.';

  @override
  String get copy_error => 'No se pudo copiar al portapapeles.';

  @override
  String get uploading => 'Espere…';

  @override
  String get upload_file => 'Enviar archivo a Vault';

  @override
  String get copy_receipt => 'Copiar recibo JSON';

  @override
  String get share_original => 'Compartir archivo original';

  @override
  String get record_not_sent => 'Espere a que el registro se registre en el servidor.';

  @override
  String get receipt_not_ready => 'El recibo aún no está listo. Reintente tras la confirmación en la cadena.';

  @override
  String get receipt_copied => 'Recibo copiado. Péguelo en verify.digitaltrust.living junto con el archivo. Contiene metadatos del registro.';

  @override
  String get receipt_error => 'No se pudo obtener el recibo. Revise la conexión e inténtelo de nuevo.';

  @override
  String get share_error => 'No se pudo compartir el archivo. Compruebe que el original sigue en el dispositivo.';

  @override
  String get upload_success => 'Archivo enviado a Vault.';

  @override
  String get upload_error => 'Vault no aceptó el archivo. Revise la conexión e inténtelo de nuevo.';

  @override
  String get devnet_disclaimer => 'Solana Devnet es una red de pruebas. Las firmas y los resúmenes no prueban la veracidad del contenido.';

  @override
  String get verify_title => 'Verificación de integridad';

  @override
  String get verify_help => 'Seleccione un registro guardado para comprobar su hash SHA-256.';

  @override
  String get verify_empty => 'No hay archivos locales para verificar.';

  @override
  String get verify_local_ok => 'SHA-256, tamaño y resumen del registro coinciden. Es una comprobación local de integridad; aquí no se verifican la firma del dispositivo ni la transacción en cadena.';

  @override
  String get verify_local_fail => 'El archivo o registro cambió: falló la comprobación de integridad.';

  @override
  String get verify_error => 'No se pudo verificar el archivo. Compruebe que el original sigue en el dispositivo.';

  @override
  String get file_upload_any => 'Wi-Fi y datos móviles (4G/5G)';

  @override
  String get upload_any_desc => 'Envío automático con cualquier conexión. Consume datos de su tarifa móvil.';

  @override
  String get upload_wifi_desc => 'Envío automático solo con conexión sin límite de datos (normalmente Wi-Fi).';

  @override
  String get upload_manual_desc => 'Enviar archivos solo al pulsar el botón en los detalles del registro.';

  @override
  String get security_section => 'Seguridad y datos locales';

  @override
  String get delete_device => 'Eliminar del dispositivo';

  @override
  String get about => 'Acerca de la aplicación';

  @override
  String get organization => 'NGO Center for Digital Trust';

  @override
  String get protocol => 'Protocolo';

  @override
  String get key_protection => 'Protección de la clave';

  @override
  String get keystore_unverified => 'Android Keystore (atestación no confirmada)';

  @override
  String get software_test => 'Clave de software (modo de prueba)';

  @override
  String get server_label => 'Servidor de registro';

  @override
  String get network_label => 'Red de cadena de bloques';

  @override
  String get development => 'Desarrollo';

  @override
  String get purge_title => '¿Eliminar todos los datos locales?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete_all => 'Eliminar todo';

  @override
  String get purge_error => 'No se pudieron eliminar todos los datos locales. Inténtelo de nuevo.';

  @override
  String get purge_success => 'Archivos locales eliminados del dispositivo.';

  @override
  String get developed_by => 'Desarrollado por';
}
