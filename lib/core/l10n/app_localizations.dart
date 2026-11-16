import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Dictionary-backed localization for English (`en`), Arabic (`ar`, RTL) and
/// Italian (`it`). Consume via the `context.l10n` extension.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ar'),
    Locale('it'),
  ];

  static const String fallbackLanguageCode = 'en';

  static bool isSupported(String languageCode) => supportedLocales
      .any((Locale locale) => locale.languageCode == languageCode);

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizations(Localizations.localeOf(context));

  String _t(String key) {
    final String languageCode = isSupported(locale.languageCode)
        ? locale.languageCode
        : fallbackLanguageCode;
    final String? value =
        _dictionary[languageCode]?[key] ?? _dictionary[fallbackLanguageCode]?[key];
    assert(value != null, 'Missing localization key: $key');
    return value ?? key;
  }

  // ── Brand ─────────────────────────────────────────────────────────────────
  String get appTitle => _t('appTitle');
  String get brandHeader => _t('brandHeader');

  // ── Home / Decider ────────────────────────────────────────────────────────
  String get stuckInTasks => _t('stuckInTasks');
  String get weWillPickTask => _t('weWillPickTask');
  String get suggestTask => _t('suggestTask');
  String get doIt => _t('doIt');
  String get rollAgain => _t('rollAgain');
  String get pendingTasks => _t('pendingTasks');
  String get viewAll => _t('viewAll');
  String get keepMomentum => _t('keepMomentum');
  String get noPendingTasks => _t('noPendingTasks');
  String get addTasks => _t('addTasks');
  String get tryAgain => _t('tryAgain');
  String get openLink => _t('openLink');
  String taskCount(int count) => count == 1
      ? _t('taskCountOne')
      : _t('taskCountMany').replaceAll('{n}', '$count');
  String get priorityHigh => _t('priorityHigh');
  String get priorityMedium => _t('priorityMedium');
  String get priorityLow => _t('priorityLow');
  String get priority => _t('priority');
  String get statusHelperPending => _t('statusHelperPending');
  String get statusHelperInProgress => _t('statusHelperInProgress');
  String get statusHelperCompleted => _t('statusHelperCompleted');
  String get deleteTask => _t('deleteTask');
  String deleteTaskConfirm(String title) =>
      _t('deleteTaskConfirm').replaceAll('{title}', title);
  String get activeTaskExists => _t('activeTaskExists');
  String get noTasksMatch => _t('noTasksMatch');
  String get clearSearch => _t('clearSearch');
  String get close => _t('close');
  String get taskTitle => _t('taskTitle');
  String get taskTitleRequired => _t('taskTitleRequired');
  String get category => _t('category');
  String get estimatedMinutes => _t('estimatedMinutes');
  String get positiveNumber => _t('positiveNumber');
  String get link => _t('link');
  String get notesLabel => _t('notesLabel');
  String get saveChanges => _t('saveChanges');
  String get saveFailed => _t('saveFailed');
  String get edit => _t('edit');
  String joinedOn(String date) => _t('joinedOn').replaceAll('{date}', date);
  String get accountAndInfo => _t('accountAndInfo');
  String get profileUpdated => _t('profileUpdated');
  String get notificationsSubtitle => _t('notificationsSubtitle');
  String get newTask => _t('newTask');
  String get couldNotOpenLink => _t('couldNotOpenLink');
  String get noPendingTasksShort => _t('noPendingTasksShort');
  String get uncategorized => _t('uncategorized');
  String minutesLong(int minutes) =>
      _t('minutesLong').replaceAll('{n}', '$minutes');
  String minutesShort(int minutes) =>
      _t('minutesShort').replaceAll('{n}', '$minutes');

  // ── Tasks ─────────────────────────────────────────────────────────────────
  String get yourList => _t('yourList');
  String get myTasks => _t('myTasks');
  String get addTask => _t('addTask');
  String get searchTasks => _t('searchTasks');
  String get pending => _t('pending');
  String get inProgress => _t('inProgress');
  String get completed => _t('completed');
  String get all => _t('all');
  String get status => _t('status');
  String get startTask => _t('startTask');
  String get returnToPending => _t('returnToPending');
  String get markCompleted => _t('markCompleted');
  String get reopenTask => _t('reopenTask');
  String get editTask => _t('editTask');
  String get savedLink => _t('savedLink');
  String get notes => _t('notes');
  String get tasks => _t('tasks');
  String get decide => _t('decide');

  // ── Categories ────────────────────────────────────────────────────────────
  String get categories => _t('categories');
  String get addCategory => _t('addCategory');
  String get newCategory => _t('newCategory');
  String get createCategory => _t('createCategory');
  String get deleteCategory => _t('deleteCategory');
  String get categoryName => _t('categoryName');
  String get categoryNameRequired => _t('categoryNameRequired');
  String get colorTag => _t('colorTag');
  String get noCategoriesTitle => _t('noCategoriesTitle');
  String get noCategoriesBody => _t('noCategoriesBody');
  String deleteCategoryConfirm(String name) =>
      _t('deleteCategoryConfirm').replaceAll('{name}', name);

  // ── Profile & Settings ────────────────────────────────────────────────────
  String get profile => _t('profile');
  String get preferences => _t('preferences');
  String get about => _t('about');
  String get account => _t('account');
  String get editDisplayName => _t('editDisplayName');
  String get displayName => _t('displayName');
  String get enterYourName => _t('enterYourName');
  String get nameCannotBeEmpty => _t('nameCannotBeEmpty');
  String get nameTooShort => _t('nameTooShort');
  String get pushNotifications => _t('pushNotifications');
  String get reminderTime => _t('reminderTime');
  String get enabled => _t('enabled');
  String get disabled => _t('disabled');
  String get theme => _t('theme');
  String get themeSystem => _t('themeSystem');
  String get themeLight => _t('themeLight');
  String get themeDark => _t('themeDark');
  String get language => _t('language');
  String get aboutApp => _t('aboutApp');
  String get aboutAppDescription => _t('aboutAppDescription');
  String get logOut => _t('logOut');
  String get logOutConfirm => _t('logOutConfirm');
  String get deleteAccount => _t('deleteAccount');
  String get deleteAccountSubtitle => _t('deleteAccountSubtitle');
  String get deleteAccountConfirm => _t('deleteAccountConfirm');

  // ── Auth ──────────────────────────────────────────────────────────────────
  String get signIn => _t('signIn');
  String get signUp => _t('signUp');
  String get email => _t('email');
  String get password => _t('password');
  String get createAccount => _t('createAccount');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get dontHaveAccount => _t('dontHaveAccount');
  String get enterDisplayNamePrompt => _t('enterDisplayNamePrompt');
  String get enterEmailPrompt => _t('enterEmailPrompt');
  String get passwordTooShort => _t('passwordTooShort');

  // ── Legal ─────────────────────────────────────────────────────────────────
  String get privacyPolicy => _t('privacyPolicy');
  String get termsOfService => _t('termsOfService');

  /// Must contain [termsOfService] and [privacyPolicy] verbatim so they can
  /// be rendered as tappable links.
  String get authLegalDisclaimer => _t('authLegalDisclaimer');

  // ── Forms & Dialogs ───────────────────────────────────────────────────────
  String get noCategoriesAvailable => _t('noCategoriesAvailable');
  String get createCategoryFirst => _t('createCategoryFirst');
  String get gotIt => _t('gotIt');
  String get addNewTask => _t('addNewTask');
  String get taskTitleHint => _t('taskTitleHint');
  String get categoryHint => _t('categoryHint');
  String get minutesHint => _t('minutesHint');
  String get urlHint => _t('urlHint');
  String get descriptionOptional => _t('descriptionOptional');
  String get descriptionHint => _t('descriptionHint');
  String get deleteCategoryTooltip => _t('deleteCategoryTooltip');

  // ── Common ────────────────────────────────────────────────────────────────
  String get retry => _t('retry');
  String get cancel => _t('cancel');
  String get save => _t('save');
  String get confirm => _t('confirm');
  String get delete => _t('delete');

  static const Map<String, Map<String, String>> _dictionary =
      <String, Map<String, String>>{
    'en': <String, String>{
      'appTitle': 'WSID?',
      'brandHeader': 'What should\nI do now?',
      'stuckInTasks': 'stuck in your tasks?',
      'weWillPickTask': 'we will pick a task for you',
      'suggestTask': 'suggest a task 🔀',
      'doIt': 'Do it 😊',
      'rollAgain': 'roll again 🔄',
      'pendingTasks': 'Pending Tasks',
      'viewAll': 'View all',
      'keepMomentum': 'Keep the momentum going',
      'noPendingTasks': 'No pending tasks found. Add tasks to get started!',
      'addTasks': 'Add Tasks',
      'tryAgain': 'Try Again',
      'openLink': 'Open link',
      'taskCountOne': '1 task',
      'taskCountMany': '{n} tasks',
      'priorityHigh': 'High priority',
      'priorityMedium': 'Medium priority',
      'priorityLow': 'Low priority',
      'priority': 'Priority',
      'statusHelperPending': 'This task is ready for a future selection.',
      'statusHelperInProgress': 'Keep going when it feels right. Your progress is saved.',
      'statusHelperCompleted': 'Need another pass? Reopen it whenever you\'re ready.',
      'deleteTask': 'Delete Task',
      'deleteTaskConfirm': 'Are you sure you want to delete "{title}"?',
      'activeTaskExists': 'You already have a task in progress. Finish or return it first.',
      'noTasksMatch': 'No tasks match your filters.',
      'clearSearch': 'Clear search',
      'close': 'Close',
      'taskTitle': 'Task title',
      'taskTitleRequired': 'Please enter a task title',
      'category': 'Category',
      'estimatedMinutes': 'Est. minutes',
      'positiveNumber': 'Enter a positive number',
      'link': 'Link',
      'notesLabel': 'Notes',
      'saveChanges': 'Save changes',
      'saveFailed': 'Couldn\'t save changes. Please try again.',
      'edit': 'Edit',
      'joinedOn': 'Joined {date}',
      'accountAndInfo': 'Account & Info',
      'profileUpdated': 'Display name updated',
      'notificationsSubtitle': 'Reminders for your active task',
      'newTask': 'New task',
      'couldNotOpenLink': 'Could not open link',
      'noPendingTasksShort': 'Nothing pending. Add a task to get started.',
      'uncategorized': 'Uncategorized',
      'minutesLong': '{n} mins',
      'minutesShort': '{n} min',
      'yourList': 'YOUR LIST',
      'myTasks': 'My Tasks',
      'addTask': '+ Add Task',
      'searchTasks': 'Search tasks',
      'pending': 'Pending',
      'inProgress': 'In Progress',
      'completed': 'Completed',
      'all': 'All',
      'status': 'Status',
      'startTask': 'Start task',
      'returnToPending': 'Return to Pending',
      'markCompleted': 'Mark completed',
      'reopenTask': 'Reopen task',
      'editTask': 'Edit Task',
      'savedLink': 'SAVED LINK',
      'notes': 'NOTES',
      'tasks': 'Tasks',
      'decide': 'Decide',
      'categories': 'Categories',
      'addCategory': 'Add Category',
      'newCategory': 'New Category',
      'createCategory': 'Create Category',
      'deleteCategory': 'Delete Category',
      'categoryName': 'Category Name',
      'categoryNameRequired': 'Please enter a category name',
      'colorTag': 'Color Tag',
      'noCategoriesTitle': 'No categories yet',
      'noCategoriesBody':
          'Create categories to organize your tasks and streamline suggestions.',
      'deleteCategoryConfirm':
          'Are you sure you want to delete "{name}"? Tasks associated with this category will not be deleted.',
      'profile': 'Profile',
      'preferences': 'Preferences',
      'about': 'About',
      'account': 'Account',
      'editDisplayName': 'Edit Display Name',
      'displayName': 'Display Name',
      'enterYourName': 'Enter your name',
      'nameCannotBeEmpty': 'Name cannot be empty.',
      'nameTooShort': 'Name must be at least 2 characters.',
      'pushNotifications': 'Push Notifications',
      'reminderTime': 'Daily Reminder Time',
      'enabled': 'Enabled',
      'disabled': 'Disabled',
      'theme': 'Theme',
      'themeSystem': 'System',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'language': 'Language',
      'aboutApp': 'About App',
      'aboutAppDescription':
          'A focused task decider that helps you pick what to work on next.',
      'logOut': 'Log Out',
      'logOutConfirm': 'Are you sure you want to log out?',
      'deleteAccount': 'Delete Account',
      'deleteAccountSubtitle': 'This action is permanent and cannot be undone.',
      'deleteAccountConfirm':
          'Your account and all associated data will be permanently deleted. This action cannot be undone.',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'createAccount': 'Create Account',
      'alreadyHaveAccount': 'Already have an account? Sign In',
      'dontHaveAccount': "Don't have an account? Sign Up",
      'enterDisplayNamePrompt': 'Please enter a display name',
      'enterEmailPrompt': 'Please enter your email',
      'passwordTooShort': 'Password must be at least 6 characters',
      'privacyPolicy': 'Privacy Policy',
      'termsOfService': 'Terms of Service',
      'authLegalDisclaimer':
          'By continuing, you agree to our Terms of Service and Privacy Policy.',
      'noCategoriesAvailable': 'No categories available',
      'createCategoryFirst':
          'Please create at least one category before adding tasks.',
      'gotIt': 'Got it',
      'addNewTask': 'Add New Task',
      'taskTitleHint': 'e.g. Finish quarterly report',
      'categoryHint': 'e.g. Work, Health, Personal',
      'minutesHint': 'e.g. 25',
      'urlHint': 'https://...',
      'descriptionOptional': 'Description (optional)',
      'descriptionHint': 'Add context, subtasks, or reference notes...',
      'deleteCategoryTooltip': 'Delete Category',
      'retry': 'Retry',
      'cancel': 'Cancel',
      'save': 'Save',
      'confirm': 'Confirm',
      'delete': 'Delete',
    },
    'ar': <String, String>{
      'appTitle': 'WSID?',
      'brandHeader': 'ماذا يجب\nأن أفعل الآن؟',
      'stuckInTasks': 'عالق في مهامك؟',
      'weWillPickTask': 'سنختار لك مهمة',
      'suggestTask': 'اقترح مهمة 🔀',
      'doIt': 'افعلها 😊',
      'rollAgain': 'جرّب مجدداً 🔄',
      'pendingTasks': 'المهام المعلقة',
      'viewAll': 'عرض الكل',
      'keepMomentum': 'حافظ على الزخم',
      'noPendingTasks': 'لا توجد مهام معلقة. أضف مهام للبدء!',
      'addTasks': 'إضافة مهام',
      'tryAgain': 'حاول مرة أخرى',
      'openLink': 'فتح الرابط',
      'taskCountOne': 'مهمة واحدة',
      'taskCountMany': '{n} مهام',
      'priorityHigh': 'أولوية عالية',
      'priorityMedium': 'أولوية متوسطة',
      'priorityLow': 'أولوية منخفضة',
      'priority': 'الأولوية',
      'statusHelperPending': 'هذه المهمة جاهزة لاختيار قادم.',
      'statusHelperInProgress': 'تابع عندما تشعر بأن الوقت مناسب. تقدّمك محفوظ.',
      'statusHelperCompleted': 'تحتاج إلى جولة أخرى؟ أعد فتحها متى شئت.',
      'deleteTask': 'حذف المهمة',
      'deleteTaskConfirm': 'هل أنت متأكد من حذف "{title}"؟',
      'activeTaskExists': 'لديك مهمة قيد التنفيذ بالفعل. أنهِها أو أرجعها أولاً.',
      'noTasksMatch': 'لا توجد مهام تطابق عوامل التصفية.',
      'clearSearch': 'مسح البحث',
      'close': 'إغلاق',
      'taskTitle': 'عنوان المهمة',
      'taskTitleRequired': 'يرجى إدخال عنوان المهمة',
      'category': 'الفئة',
      'estimatedMinutes': 'الدقائق المقدّرة',
      'positiveNumber': 'أدخل رقماً موجباً',
      'link': 'الرابط',
      'notesLabel': 'ملاحظات',
      'saveChanges': 'حفظ التغييرات',
      'saveFailed': 'تعذّر حفظ التغييرات. حاول مرة أخرى.',
      'edit': 'تعديل',
      'joinedOn': 'انضم في {date}',
      'accountAndInfo': 'الحساب والمعلومات',
      'profileUpdated': 'تم تحديث الاسم المعروض',
      'notificationsSubtitle': 'تذكيرات لمهمتك الحالية',
      'newTask': 'مهمة جديدة',
      'couldNotOpenLink': 'تعذّر فتح الرابط',
      'noPendingTasksShort': 'لا شيء معلق. أضف مهمة للبدء.',
      'uncategorized': 'بدون فئة',
      'minutesLong': '{n} دقيقة',
      'minutesShort': '{n} د',
      'yourList': 'قائمتك',
      'myTasks': 'مهامي',
      'addTask': '+ إضافة مهمة',
      'searchTasks': 'البحث في المهام',
      'pending': 'معلقة',
      'inProgress': 'قيد التنفيذ',
      'completed': 'مكتملة',
      'all': 'الكل',
      'status': 'الحالة',
      'startTask': 'ابدأ المهمة',
      'returnToPending': 'إرجاع إلى المعلقة',
      'markCompleted': 'وضع علامة مكتملة',
      'reopenTask': 'إعادة فتح المهمة',
      'editTask': 'تعديل المهمة',
      'savedLink': 'الرابط المحفوظ',
      'notes': 'ملاحظات',
      'tasks': 'المهام',
      'decide': 'قرّر',
      'categories': 'الفئات',
      'addCategory': 'إضافة فئة',
      'newCategory': 'فئة جديدة',
      'createCategory': 'إنشاء فئة',
      'deleteCategory': 'حذف الفئة',
      'categoryName': 'اسم الفئة',
      'categoryNameRequired': 'يرجى إدخال اسم الفئة',
      'colorTag': 'لون الوسم',
      'noCategoriesTitle': 'لا توجد فئات بعد',
      'noCategoriesBody': 'أنشئ فئات لتنظيم مهامك وتحسين الاقتراحات.',
      'deleteCategoryConfirm':
          'هل أنت متأكد من حذف "{name}"؟ لن يتم حذف المهام المرتبطة بهذه الفئة.',
      'profile': 'الملف الشخصي',
      'preferences': 'التفضيلات',
      'about': 'حول',
      'account': 'الحساب',
      'editDisplayName': 'تعديل الاسم المعروض',
      'displayName': 'الاسم المعروض',
      'enterYourName': 'أدخل اسمك',
      'nameCannotBeEmpty': 'لا يمكن أن يكون الاسم فارغاً.',
      'nameTooShort': 'يجب أن يتكون الاسم من حرفين على الأقل.',
      'pushNotifications': 'الإشعارات الفورية',
      'reminderTime': 'وقت التذكير اليومي',
      'enabled': 'مفعّلة',
      'disabled': 'معطّلة',
      'theme': 'المظهر',
      'themeSystem': 'النظام',
      'themeLight': 'فاتح',
      'themeDark': 'داكن',
      'language': 'اللغة',
      'aboutApp': 'عن التطبيق',
      'aboutAppDescription': 'أداة تركيز تساعدك على اختيار ما تعمل عليه تالياً.',
      'logOut': 'تسجيل الخروج',
      'logOutConfirm': 'هل أنت متأكد من تسجيل الخروج؟',
      'deleteAccount': 'حذف الحساب',
      'deleteAccountSubtitle': 'هذا الإجراء نهائي ولا يمكن التراجع عنه.',
      'deleteAccountConfirm':
          'سيتم حذف حسابك وجميع البيانات المرتبطة به نهائياً. لا يمكن التراجع عن هذا الإجراء.',
      'signIn': 'تسجيل الدخول',
      'signUp': 'إنشاء حساب',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'createAccount': 'إنشاء حساب',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ تسجيل الدخول',
      'dontHaveAccount': 'ليس لديك حساب؟ إنشاء حساب',
      'enterDisplayNamePrompt': 'يرجى إدخال اسم العرض',
      'enterEmailPrompt': 'يرجى إدخال بريدك الإلكتروني',
      'passwordTooShort': 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل',
      'privacyPolicy': 'سياسة الخصوصية',
      'termsOfService': 'شروط الخدمة',
      'authLegalDisclaimer':
          'بالمتابعة، فإنك توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا.',
      'noCategoriesAvailable': 'لا توجد فئات متاحة',
      'createCategoryFirst': 'يرجى إنشاء فئة واحدة على الأقل قبل إضافة المهام.',
      'gotIt': 'فهمت',
      'addNewTask': 'إضافة مهمة جديدة',
      'taskTitleHint': 'مثال: إنهاء التقرير الربع سنوي',
      'categoryHint': 'مثال: العمل، الصحة، شخصي',
      'minutesHint': 'مثال: 25',
      'urlHint': 'https://...',
      'descriptionOptional': 'الوصف (اختياري)',
      'descriptionHint': 'أضف سياقاً أو مهام فرعية أو ملاحظات...',
      'deleteCategoryTooltip': 'حذف الفئة',
      'retry': 'إعادة المحاولة',
      'cancel': 'إلغاء',
      'save': 'حفظ',
      'confirm': 'تأكيد',
      'delete': 'حذف',
    },
    'it': <String, String>{
      'appTitle': 'WSID?',
      'brandHeader': 'Cosa dovrei\nfare adesso?',
      'stuckInTasks': 'bloccato nelle tue attività?',
      'weWillPickTask': 'sceglieremo un\'attività per te',
      'suggestTask': 'suggerisci un\'attività 🔀',
      'doIt': 'Fallo 😊',
      'rollAgain': 'ritenta 🔄',
      'pendingTasks': 'Attività in sospeso',
      'viewAll': 'Vedi tutto',
      'keepMomentum': 'Mantieni lo slancio',
      'noPendingTasks':
          'Nessuna attività in sospeso. Aggiungi attività per iniziare!',
      'addTasks': 'Aggiungi attività',
      'tryAgain': 'Riprova',
      'openLink': 'Apri link',
      'taskCountOne': '1 attività',
      'taskCountMany': '{n} attività',
      'priorityHigh': 'Priorità alta',
      'priorityMedium': 'Priorità media',
      'priorityLow': 'Priorità bassa',
      'priority': 'Priorità',
      'statusHelperPending': 'Questa attività è pronta per una selezione futura.',
      'statusHelperInProgress': 'Continua quando ti senti pronto. I tuoi progressi sono salvati.',
      'statusHelperCompleted': 'Serve un altro passaggio? Riaprila quando vuoi.',
      'deleteTask': 'Elimina attività',
      'deleteTaskConfirm': 'Vuoi davvero eliminare "{title}"?',
      'activeTaskExists': 'Hai già un\'attività in corso. Completala o rimettila in sospeso prima.',
      'noTasksMatch': 'Nessuna attività corrisponde ai filtri.',
      'clearSearch': 'Cancella ricerca',
      'close': 'Chiudi',
      'taskTitle': 'Titolo attività',
      'taskTitleRequired': 'Inserisci un titolo per l\'attività',
      'category': 'Categoria',
      'estimatedMinutes': 'Minuti stimati',
      'positiveNumber': 'Inserisci un numero positivo',
      'link': 'Link',
      'notesLabel': 'Note',
      'saveChanges': 'Salva modifiche',
      'saveFailed': 'Impossibile salvare le modifiche. Riprova.',
      'edit': 'Modifica',
      'joinedOn': 'Iscritto dal {date}',
      'accountAndInfo': 'Account e informazioni',
      'profileUpdated': 'Nome visualizzato aggiornato',
      'notificationsSubtitle': 'Promemoria per la tua attività in corso',
      'newTask': 'Nuova attività',
      'couldNotOpenLink': 'Impossibile aprire il link',
      'noPendingTasksShort': 'Niente in sospeso. Aggiungi un\'attività per iniziare.',
      'uncategorized': 'Senza categoria',
      'minutesLong': '{n} min',
      'minutesShort': '{n} min',
      'yourList': 'LA TUA LISTA',
      'myTasks': 'Le mie attività',
      'addTask': '+ Aggiungi attività',
      'searchTasks': 'Cerca attività',
      'pending': 'In sospeso',
      'inProgress': 'In corso',
      'completed': 'Completate',
      'all': 'Tutte',
      'status': 'Stato',
      'startTask': 'Inizia attività',
      'returnToPending': 'Rimetti in sospeso',
      'markCompleted': 'Segna come completata',
      'reopenTask': 'Riapri attività',
      'editTask': 'Modifica attività',
      'savedLink': 'LINK SALVATO',
      'notes': 'NOTE',
      'tasks': 'Attività',
      'decide': 'Decidi',
      'categories': 'Categorie',
      'addCategory': 'Aggiungi categoria',
      'newCategory': 'Nuova categoria',
      'createCategory': 'Crea categoria',
      'deleteCategory': 'Elimina categoria',
      'categoryName': 'Nome categoria',
      'categoryNameRequired': 'Inserisci un nome per la categoria',
      'colorTag': 'Colore etichetta',
      'noCategoriesTitle': 'Nessuna categoria',
      'noCategoriesBody':
          'Crea categorie per organizzare le tue attività e migliorare i suggerimenti.',
      'deleteCategoryConfirm':
          'Vuoi davvero eliminare "{name}"? Le attività associate a questa categoria non verranno eliminate.',
      'profile': 'Profilo',
      'preferences': 'Preferenze',
      'about': 'Informazioni',
      'account': 'Account',
      'editDisplayName': 'Modifica nome visualizzato',
      'displayName': 'Nome visualizzato',
      'enterYourName': 'Inserisci il tuo nome',
      'nameCannotBeEmpty': 'Il nome non può essere vuoto.',
      'nameTooShort': 'Il nome deve contenere almeno 2 caratteri.',
      'pushNotifications': 'Notifiche push',
      'reminderTime': 'Orario del promemoria',
      'enabled': 'Attive',
      'disabled': 'Disattivate',
      'theme': 'Tema',
      'themeSystem': 'Sistema',
      'themeLight': 'Chiaro',
      'themeDark': 'Scuro',
      'language': 'Lingua',
      'aboutApp': 'Informazioni sull\'app',
      'aboutAppDescription':
          'Un assistente che ti aiuta a scegliere su cosa lavorare dopo.',
      'logOut': 'Esci',
      'logOutConfirm': 'Sei sicuro di voler uscire?',
      'deleteAccount': 'Elimina account',
      'deleteAccountSubtitle':
          'Questa azione è permanente e non può essere annullata.',
      'deleteAccountConfirm':
          'Il tuo account e tutti i dati associati verranno eliminati definitivamente. Questa azione non può essere annullata.',
      'signIn': 'Accedi',
      'signUp': 'Registrati',
      'email': 'Email',
      'password': 'Password',
      'createAccount': 'Crea account',
      'alreadyHaveAccount': 'Hai già un account? Accedi',
      'dontHaveAccount': 'Non hai un account? Registrati',
      'enterDisplayNamePrompt': 'Inserisci un nome visualizzato',
      'enterEmailPrompt': 'Inserisci la tua email',
      'passwordTooShort': 'La password deve contenere almeno 6 caratteri',
      'privacyPolicy': 'Informativa sulla privacy',
      'termsOfService': 'Termini di servizio',
      'authLegalDisclaimer':
          'Continuando, accetti i nostri Termini di servizio e l\'Informativa sulla privacy.',
      'noCategoriesAvailable': 'Nessuna categoria disponibile',
      'createCategoryFirst':
          'Crea almeno una categoria prima di aggiungere attività.',
      'gotIt': 'Ho capito',
      'addNewTask': 'Aggiungi nuova attività',
      'taskTitleHint': 'es. Concludere il report trimestrale',
      'categoryHint': 'es. Lavoro, Salute, Personale',
      'minutesHint': 'es. 25',
      'urlHint': 'https://...',
      'descriptionOptional': 'Descrizione (opzionale)',
      'descriptionHint': 'Aggiungi contesto, sotto-attività o note...',
      'deleteCategoryTooltip': 'Elimina categoria',
      'retry': 'Riprova',
      'cancel': 'Annulla',
      'save': 'Salva',
      'confirm': 'Conferma',
      'delete': 'Elimina',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.isSupported(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
