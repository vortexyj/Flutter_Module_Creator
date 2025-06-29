#!/bin/bash

# --- Script to Scaffold Flutter Module and Features ---

# --- Helper Functions ---
snake_to_pascal_case() {
  echo "$1" | awk -F_ '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print}' OFS=""
}

pascal_to_camel_case() {
  local pascal_string="$1"
  local first_char_lower=$(echo "${pascal_string:0:1}" | tr '[:upper:]' '[:lower:]')
  local rest_of_string="${pascal_string:1}"
  echo "${first_char_lower}${rest_of_string}"
}
# =============================================================================
# === FINAL HELPER FUNCTION (USING ENVIRONMENT VARIABLE) ======================
# =============================================================================
#
# This version uses an environment variable to pass multi-line content to awk,
# which robustly solves the "newline in string" error.
#
insert_before() {
  local file="$1"
  local pattern="$2"
  local content="$3"
  local tmp_file

  # --- Start of Modification Attempt ---
  echo "  -> Modifying File: '$file'"

  # 1. Check if the file exists and is readable
  if [ ! -r "$file" ]; then
    echo "     [ERROR] File not found or is not readable. Skipping."
    return 1
  fi

  # 2. Verify the anchor pattern exists
  if ! grep -qF -- "$pattern" "$file"; then
    echo "     [WARNING] Anchor pattern not found in file. Skipping modification."
    echo "     [Searched For] '$pattern'"
    return 1
  fi

  # 3. If anchor is found, export content and run awk
  echo "     [OK] Anchor found. Inserting content."
  tmp_file=$(mktemp)
  if [ -z "$tmp_file" ]; then
    echo "     [ERROR] Could not create temporary file."
    return 1
  fi

  # Export the content to an environment variable that awk can safely access.
  export CONTENT_FOR_AWK="$content"

  # awk now reads the multi-line content from ENVIRON, which works correctly.
  awk -v p="$pattern" '
    index($0, p) { print ENVIRON["CONTENT_FOR_AWK"] }
    { print }
  ' "$file" > "$tmp_file"
  
  # Unset the environment variable to keep things clean.
  unset CONTENT_FOR_AWK

  # 4. Check if awk and the file move succeeded
  if [ $? -eq 0 ]; then
    mv "$tmp_file" "$file"
    if [ $? -eq 0 ]; then
       echo "     [SUCCESS] File modified successfully."
    else
       echo "     [ERROR] Failed to move temporary file back to original."
       rm -f "$tmp_file"
       return 1
    fi
  else
    echo "     [ERROR] awk command failed. No changes were made."
    rm -f "$tmp_file"
    return 1
  fi
  # --- End of Modification Attempt ---
}
# =============================================================================
# === END OF FINAL HELPER FUNCTION ============================================
# =============================================================================

# --- Main Menu ---
echo "Flutter Module & Feature Scaffolder"
echo "-----------------------------------"
echo "What would you like to do?"
echo "  1) Create a new Module and its first Feature"
echo "  2) Add a new Feature to an existing Module"
read -p "Enter your choice (1 or 2): " SCRIPT_MODE

# ==============================================================================
# --- MODE 1: CREATE A NEW MODULE AND ITS FIRST FEATURE ---
# ==============================================================================
if [ "$SCRIPT_MODE" == "1" ]; then

  echo ""
  echo "--- Mode 1: Create New Module ---"
  
  echo "Enter the name for the new Flutter Module (package, snake_case):"
  read MODULE_NAME_SNAKE

  if [ -z "$MODULE_NAME_SNAKE" ]; then echo "Error: Module name cannot be empty."; exit 1; fi
  if [ -d "$MODULE_NAME_SNAKE" ]; then echo "Error: A directory named '$MODULE_NAME_SNAKE' already exists here."; exit 1; fi

  echo "Creating Flutter package (module): $MODULE_NAME_SNAKE..."
  flutter create --template=package "$MODULE_NAME_SNAKE"

  if [ ! -d "$MODULE_NAME_SNAKE" ] || [ ! -f "$MODULE_NAME_SNAKE/pubspec.yaml" ]; then echo "Error: Failed to create module '$MODULE_NAME_SNAKE'."; exit 1; fi
  echo "Module '$MODULE_NAME_SNAKE' created successfully."
  echo ""

  echo "Changing directory to '$MODULE_NAME_SNAKE'..."
  cd "$MODULE_NAME_SNAKE"
  if [ $? -ne 0 ]; then echo "Error: Failed to change directory to '$MODULE_NAME_SNAKE'."; exit 1; fi
  echo "Now operating inside module: $PWD"
  echo ""

  MODULE_NAME_PASCAL=$(snake_to_pascal_case "$MODULE_NAME_SNAKE")
  MODULE_NAME_CAMEL=$(pascal_to_camel_case "$MODULE_NAME_PASCAL")

  echo "Enter the name for the initial FEATURE (e.g., user_login):"
  read FEATURE_NAME_SNAKE

  if [ -z "$FEATURE_NAME_SNAKE" ]; then echo "Error: Feature name cannot be empty."; exit 1; fi
  FEATURE_NAME_PASCAL=$(snake_to_pascal_case "$FEATURE_NAME_SNAKE")
  FEATURE_NAME_CAMEL=$(pascal_to_camel_case "$FEATURE_NAME_PASCAL")

  BASE_PATH="./lib"
  if [ ! -d "$BASE_PATH" ]; then echo "Error: '$BASE_PATH' directory not found inside '$PWD'."; exit 1; fi

  # --- Define Paths and Filenames ---
  FILE_LIB_MODULE_MAIN="$BASE_PATH/${MODULE_NAME_SNAKE}.dart"
  FILE_LIB_MODULE_ROUTER="$BASE_PATH/${MODULE_NAME_SNAKE}_screen_router.dart"
  DATA_PATH="$BASE_PATH/data"
  DATA_MODULE_REPO_PATH="$DATA_PATH/${MODULE_NAME_SNAKE}_repository"
  FILE_DATA_MODULE_REPO_IMPL="$DATA_MODULE_REPO_PATH/${MODULE_NAME_SNAKE}_repository_impl.dart"
  DATA_MODELS_STATIC_PATH="$DATA_PATH/models"
  DATA_MODELS_FEATURE_PATH="$DATA_MODELS_STATIC_PATH/${FEATURE_NAME_SNAKE}"
  FILE_DATA_FEATURE_REQUEST="$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_request.dart"
  FILE_DATA_FEATURE_REQUEST_MODEL="$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_request_model.dart"
  FILE_DATA_FEATURE_RESPONSE_MODEL="$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_response_model.dart"
  DATA_REMOTE_PATH="$DATA_PATH/remote_data_source"
  FILE_DATA_MODULE_REMOTE_SOURCE="$DATA_REMOTE_PATH/${MODULE_NAME_SNAKE}_remote_data_source.dart"
  DI_PATH="$BASE_PATH/di"
  FILE_DI_MODULE_MAIN="$DI_PATH/${MODULE_NAME_SNAKE}_di.dart"
  DOMAIN_PATH="$BASE_PATH/domain"
  DOMAIN_MODULE_REPO_PATH="$DOMAIN_PATH/${MODULE_NAME_SNAKE}_repository"
  FILE_DOMAIN_MODULE_REPO="$DOMAIN_MODULE_REPO_PATH/${MODULE_NAME_SNAKE}_repository.dart"
  DOMAIN_MODULE_USECASE_BASE_PATH="$DOMAIN_PATH/${MODULE_NAME_SNAKE}_usecase"
  DOMAIN_FEATURE_USECASE_PATH="$DOMAIN_MODULE_USECASE_BASE_PATH/${FEATURE_NAME_SNAKE}_usecase"
  FILE_DOMAIN_FEATURE_USECASE="$DOMAIN_FEATURE_USECASE_PATH/${FEATURE_NAME_SNAKE}_usecase.dart"
  PRESENTATION_PATH="$BASE_PATH/presentation"
  PRES_UI_PATH="$PRESENTATION_PATH/Ui"
  PRES_UI_SCREENS_PATH="$PRES_UI_PATH/screens"
  FILE_PRES_FEATURE_SCREEN_VIEW="$PRES_UI_SCREENS_PATH/${FEATURE_NAME_SNAKE}_screen_view.dart"
  PRES_UI_WIDGET_PATH="$PRES_UI_PATH/widget"
  PRES_CUBITS_BASE_PATH="$PRESENTATION_PATH/cubits"
  PRES_FEATURE_CUBIT_PATH="$PRES_CUBITS_BASE_PATH/${FEATURE_NAME_SNAKE}"
  FILE_PRES_FEATURE_CUBIT="$PRES_FEATURE_CUBIT_PATH/${FEATURE_NAME_SNAKE}_cubit.dart"
  FILE_PRES_FEATURE_CUBIT_STATE="$PRES_FEATURE_CUBIT_PATH/${FEATURE_NAME_SNAKE}_state.dart"

  # --- Create Directory Structure ---
  echo "Creating directories..."
  mkdir -p "$DATA_MODULE_REPO_PATH" "$DATA_MODELS_FEATURE_PATH" "$DATA_REMOTE_PATH" "$DI_PATH" "$DOMAIN_MODULE_REPO_PATH" "$DOMAIN_FEATURE_USECASE_PATH" "$PRES_UI_SCREENS_PATH" "$PRES_UI_WIDGET_PATH" "$PRES_FEATURE_CUBIT_PATH"
  echo "Directories created."
  echo ""

  # --- Create Files and Populate Content with ANCHORS ---
  echo "Creating files and populating content..."
  
  cat <<EOF > "$FILE_LIB_MODULE_MAIN"
export './${MODULE_NAME_SNAKE}_screen_router.dart';
EOF
  echo "Created/Updated: $FILE_LIB_MODULE_MAIN"
  
  cat <<EOF > "$FILE_LIB_MODULE_ROUTER"
import 'package:core/utils/animations.dart';
import 'package:flutter/material.dart';
import 'presentation/Ui/screens/${FEATURE_NAME_SNAKE}_screen_view.dart';
// [Adding_new_router_import_here_dont_remove_this_command_!!!]

class ${MODULE_NAME_PASCAL}ScreenRouter {
  ${MODULE_NAME_PASCAL}ScreenRouter._();

  static Route? onGenerateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case ${FEATURE_NAME_PASCAL}ScreenView.id:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ${FEATURE_NAME_PASCAL}ScreenView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.slideAnimation(animation, child);
          },
        );
      // [Adding_new_router_case_here_dont_remove_this_command_!!!]
      default:
        return null; 
    }
  }
}

class ${MODULE_NAME_PASCAL}Screens {
  ${MODULE_NAME_PASCAL}Screens._();
  static const String ${FEATURE_NAME_CAMEL}Screen = ${FEATURE_NAME_PASCAL}ScreenView.id;
  // [Adding_new_router_screen_id_here_dont_remove_this_command_!!!]
}
EOF
  echo "Created: $FILE_LIB_MODULE_ROUTER"

  cat <<EOF > "$FILE_DOMAIN_MODULE_REPO"
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import '../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
// [Adding_new_model_import_here_dont_remove_this_command_!!!]

abstract class ${MODULE_NAME_PASCAL}Repository {
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> ${FEATURE_NAME_SNAKE}(
      {required ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data});
  // [Adding_new_repo_method_here_dont_remove_this_command_!!!]
}
EOF
  echo "Created: $FILE_DOMAIN_MODULE_REPO"

  cat <<EOF > "$FILE_DATA_MODULE_REPO_IMPL"
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import '../../domain/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';
import '../remote_data_source/${MODULE_NAME_SNAKE}_remote_data_source.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
// [Adding_new_model_import_here_dont_remove_this_command_!!!]

class ${MODULE_NAME_PASCAL}RepositoryImpl implements ${MODULE_NAME_PASCAL}Repository {
  final ${MODULE_NAME_PASCAL}RemoteDataSource authRemoteDataSource;

  ${MODULE_NAME_PASCAL}RepositoryImpl({required this.authRemoteDataSource});

  @override
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> ${FEATURE_NAME_SNAKE}(
      {required ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data}) async {
    try {
      final response = await authRemoteDataSource.${FEATURE_NAME_SNAKE}(${FEATURE_NAME_SNAKE}Data);
      return Right(response);
    } on Exception catch (error) {
      return Left(FailureHandler(error).getExceptionFailure());
    }
  }
  // [Adding_new_repo_impl_method_here_dont_remove_this_command_!!!]
}
EOF
  echo "Created: $FILE_DATA_MODULE_REPO_IMPL"

  cat <<EOF > "$FILE_DATA_MODULE_REMOTE_SOURCE"
import 'package:core/core.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
// [Adding_new_model_import_here_dont_remove_this_command_!!!]

abstract class ${MODULE_NAME_PASCAL}RemoteDataSource {
  Future<${FEATURE_NAME_PASCAL}Response> ${FEATURE_NAME_SNAKE}(
      ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data);
  // [Adding_new_datasource_method_here_dont_remove_this_command_!!!]
}

class ${MODULE_NAME_PASCAL}RemoteDataSourceImpl implements ${MODULE_NAME_PASCAL}RemoteDataSource {
  final Network network;
  ${MODULE_NAME_PASCAL}RemoteDataSourceImpl({required this.network});

  @override
  Future<${FEATURE_NAME_PASCAL}Response> ${FEATURE_NAME_SNAKE}(
      ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data) async {
    final apiRequest = ${FEATURE_NAME_PASCAL}Request(${FEATURE_NAME_SNAKE}Data);
    final result = await network.send(
      request: apiRequest,
      responseFromMap: (map) => ${FEATURE_NAME_PASCAL}Response.fromJson(map),
    );
    return result;
  }
  // [Adding_new_datasource_impl_method_here_dont_remove_this_command_!!!]
}
EOF
  echo "Created: $FILE_DATA_MODULE_REMOTE_SOURCE"

  cat <<EOF > "$FILE_DI_MODULE_MAIN"
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import '../domain/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';
import '../domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart';
import '../data/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository_impl.dart';
import '../data/remote_data_source/${MODULE_NAME_SNAKE}_remote_data_source.dart';
import '../presentation/cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart';
// [Adding_new_di_import_here_dont_remove_this_command_!!!]

final di = GetIt.instance;

class ${MODULE_NAME_PASCAL}DI {
  ${MODULE_NAME_PASCAL}DI() {
    call();
  }

  void call() {
    di
      ..registerFactory<${MODULE_NAME_PASCAL}RemoteDataSource>(
          () => ${MODULE_NAME_PASCAL}RemoteDataSourceImpl(network: di()))
      ..registerFactory<${MODULE_NAME_PASCAL}Repository>(() => ${MODULE_NAME_PASCAL}RepositoryImpl(
            authRemoteDataSource: di(),
          ))
      ..registerFactory(() => ${FEATURE_NAME_PASCAL}UseCase(repository: di()))
      ..registerFactory(() => ${FEATURE_NAME_PASCAL}Cubit(di(),di()))
      // [Adding_new_di_dependency_here_dont_remove_this_command_!!!]
      ;
  }
}
EOF
  echo "Created: $FILE_DI_MODULE_MAIN"

  cat <<EOF > "$FILE_DATA_FEATURE_REQUEST"
import 'package:network/network.dart';
import './${FEATURE_NAME_SNAKE}_request_model.dart';

class ${FEATURE_NAME_PASCAL}Request with Request, PostRequest {
  const ${FEATURE_NAME_PASCAL}Request(this.requestModel);
  @override
  final ${FEATURE_NAME_PASCAL}RequestModel requestModel;
  @override
  String get path => '/${FEATURE_NAME_SNAKE}';
}
EOF
  echo "Created: $FILE_DATA_FEATURE_REQUEST"

  cat <<EOF > "$FILE_DATA_FEATURE_REQUEST_MODEL"
import 'package:network/network.dart';

class ${FEATURE_NAME_PASCAL}RequestModel extends RequestModel {
  ${FEATURE_NAME_PASCAL}RequestModel({RequestProgressListener? progressListener}) : super(progressListener);
  @override
  Future<Map<String, dynamic>> toMap() async => {};
  @override
  List<Object?> get props => [];
}
EOF
  echo "Created: $FILE_DATA_FEATURE_REQUEST_MODEL"

  cat <<EOF > "$FILE_DATA_FEATURE_RESPONSE_MODEL"
class ${FEATURE_NAME_PASCAL}Response {
  ${FEATURE_NAME_PASCAL}Response();
  factory ${FEATURE_NAME_PASCAL}Response.fromJson(Map<String, dynamic> json) => ${FEATURE_NAME_PASCAL}Response();
  Map<String, dynamic> toJson() => {};
}
EOF
  echo "Created: $FILE_DATA_FEATURE_RESPONSE_MODEL"

  cat <<EOF > "$FILE_DOMAIN_FEATURE_USECASE"
import 'package:core/packages/dartz/dartz.dart';
import 'package:core/usecase/usecase.dart';
import 'package:failures/failures.dart';
import '../../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
import '../../${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';

class ${FEATURE_NAME_PASCAL}UseCase
    implements UseCase<${FEATURE_NAME_PASCAL}Response, ${FEATURE_NAME_PASCAL}RequestModel> {
  final ${MODULE_NAME_PASCAL}Repository repository;

  ${FEATURE_NAME_PASCAL}UseCase({required this.repository});

  @override
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> call(
      ${FEATURE_NAME_PASCAL}RequestModel params) async {
    return await repository.${FEATURE_NAME_SNAKE}(${FEATURE_NAME_SNAKE}Data: params);
  }
}
EOF
  echo "Created: $FILE_DOMAIN_FEATURE_USECASE"

  cat <<EOF > "$FILE_PRES_FEATURE_CUBIT_STATE"
part of '${FEATURE_NAME_SNAKE}_cubit.dart';

class ${FEATURE_NAME_PASCAL}State extends BaseState {
  const ${FEATURE_NAME_PASCAL}State({this.failure, this.featureData, super.screenLoading = false});
  final Failure? failure;
  final ${FEATURE_NAME_PASCAL}Response? featureData;

  @override
  ${FEATURE_NAME_PASCAL}State copyWith({Failure? failure, bool? screenLoading, ${FEATURE_NAME_PASCAL}Response? featureData}) {
    return ${FEATURE_NAME_PASCAL}State(
      failure: failure ?? this.failure,
      screenLoading: screenLoading ?? this.screenLoading,
      featureData: featureData ?? this.featureData,
    );
  }
  @override
  List<Object?> get props => [screenLoading, failure, featureData];
}
EOF
  echo "Created: $FILE_PRES_FEATURE_CUBIT_STATE"

  cat <<EOF > "$FILE_PRES_FEATURE_CUBIT"
import 'package:core/core.dart';
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import 'package:local_storage/local_storage.dart';
import '../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
import '../../../domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart';
part '${FEATURE_NAME_SNAKE}_state.dart';

class ${FEATURE_NAME_PASCAL}Cubit extends BaseCubit<${FEATURE_NAME_PASCAL}State> {
  final LocalStorage localStorage;
  final ${FEATURE_NAME_PASCAL}UseCase ${FEATURE_NAME_CAMEL}UseCase;

${FEATURE_NAME_PASCAL}Cubit(this.localStorage, this.${FEATURE_NAME_CAMEL}UseCase)
      : super(const ${FEATURE_NAME_PASCAL}State());
  @override
  Future<void> initState() async {}

  Future<void> get${FEATURE_NAME_PASCAL}() async {
    emit(state.copyWith(screenLoading: true));
    final Either<Failure, ${FEATURE_NAME_PASCAL}Response> response =
        await ${FEATURE_NAME_CAMEL}UseCase.call(${FEATURE_NAME_PASCAL}RequestModel());
    response.fold((failure) => emit(state.copyWith(failure: failure, screenLoading: false)), (data) => emit(state.copyWith(featureData: data, screenLoading: false)));
  }
}
EOF
  echo "Created: $FILE_PRES_FEATURE_CUBIT"

  cat <<EOF > "$FILE_PRES_FEATURE_SCREEN_VIEW"
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../../cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart';

class ${FEATURE_NAME_PASCAL}ScreenView extends BaseView<${FEATURE_NAME_PASCAL}Cubit> {
  static const String id = '/${FEATURE_NAME_PASCAL}ScreenView';
  const ${FEATURE_NAME_PASCAL}ScreenView({super.key});
  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: Text('${FEATURE_NAME_PASCAL} Screen'));
  @override
  Widget body(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.whiteColor, body: Center(child: Text('Content for ${FEATURE_NAME_PASCAL}ScreenView')));
  }
}
EOF
  echo "Created: $FILE_PRES_FEATURE_SCREEN_VIEW"
  
  echo ""
  echo "✅ Flutter module '$MODULE_NAME_SNAKE' and initial feature '$FEATURE_NAME_SNAKE' created successfully."
  cd ..
  echo "Returned to: $PWD"
# ==============================================================================
# --- MODE 2: ADD A NEW FEATURE TO AN EXISTING MODULE (REVISED) ---
# ==============================================================================
elif [ "$SCRIPT_MODE" == "2" ]; then

  echo ""
  echo "--- Mode 2: Add New Feature to Existing Module ---"

  MODULE_NAME_SNAKE=$(basename "$PWD")
  echo "Operating in module: $MODULE_NAME_SNAKE"

  if [ ! -f "pubspec.yaml" ] || [ ! -d "lib" ]; then echo "Error: This does not appear to be the root of a Flutter module."; exit 1; fi

  echo "Enter the name for the NEW feature to add to '$MODULE_NAME_SNAKE':"
  read FEATURE_NAME_SNAKE

  if [ -z "$FEATURE_NAME_SNAKE" ]; then echo "Error: New feature name cannot be empty."; exit 1; fi
  
  MODULE_NAME_PASCAL=$(snake_to_pascal_case "$MODULE_NAME_SNAKE")
  FEATURE_NAME_PASCAL=$(snake_to_pascal_case "$FEATURE_NAME_SNAKE")
  FEATURE_NAME_CAMEL=$(pascal_to_camel_case "$FEATURE_NAME_PASCAL")
  BASE_PATH="./lib"

  echo ""
  echo "Adding feature '$FEATURE_NAME_SNAKE' to module '$MODULE_NAME_SNAKE'..."
  echo ""

  # --- Define Paths for NEW files and SHARED files ---
  DATA_MODELS_FEATURE_PATH="$BASE_PATH/data/models/${FEATURE_NAME_SNAKE}"
  DOMAIN_FEATURE_USECASE_PATH="$BASE_PATH/domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase"
  PRES_FEATURE_CUBIT_PATH="$BASE_PATH/presentation/cubits/${FEATURE_NAME_SNAKE}"
  
  FILE_LIB_MODULE_ROUTER="$BASE_PATH/${MODULE_NAME_SNAKE}_screen_router.dart"
  FILE_DOMAIN_MODULE_REPO="$BASE_PATH/domain/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart"
  FILE_DATA_MODULE_REPO_IMPL="$BASE_PATH/data/${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository_impl.dart"
  FILE_DATA_MODULE_REMOTE_SOURCE="$BASE_PATH/data/remote_data_source/${MODULE_NAME_SNAKE}_remote_data_source.dart"
  FILE_DI_MODULE_MAIN="$BASE_PATH/di/${MODULE_NAME_SNAKE}_di.dart"

  # --- Create NEW Directories ---
  echo "Creating new directories for feature '$FEATURE_NAME_SNAKE'..."
  mkdir -p "$DATA_MODELS_FEATURE_PATH" "$DOMAIN_FEATURE_USECASE_PATH" "$PRES_FEATURE_CUBIT_PATH"
  echo "New directories created."
  echo ""

  # --- Create and Populate NEW Files for the new feature ---
  echo "Creating new files for feature '$FEATURE_NAME_SNAKE'..."
  
cat <<EOF > "$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_request.dart"
import 'package:network/network.dart';
import './${FEATURE_NAME_SNAKE}_request_model.dart';

class ${FEATURE_NAME_PASCAL}Request with Request, PostRequest {
  const ${FEATURE_NAME_PASCAL}Request(this.requestModel);
  @override
  final ${FEATURE_NAME_PASCAL}RequestModel requestModel;
  @override
  String get path => '/${FEATURE_NAME_SNAKE}';
}
EOF
cat <<EOF > "$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_request_model.dart"
import 'package:network/network.dart';

class ${FEATURE_NAME_PASCAL}RequestModel extends RequestModel {
  ${FEATURE_NAME_PASCAL}RequestModel({RequestProgressListener? progressListener}) : super(progressListener);
  @override
  Future<Map<String, dynamic>> toMap() async => {};
  @override
  List<Object?> get props => [];
}
EOF
cat <<EOF > "$DATA_MODELS_FEATURE_PATH/${FEATURE_NAME_SNAKE}_response_model.dart"
class ${FEATURE_NAME_PASCAL}Response {
  ${FEATURE_NAME_PASCAL}Response();
  factory ${FEATURE_NAME_PASCAL}Response.fromJson(Map<String, dynamic> json) => ${FEATURE_NAME_PASCAL}Response();
  Map<String, dynamic> toJson() => {};
}
EOF
cat <<EOF > "$DOMAIN_FEATURE_USECASE_PATH/${FEATURE_NAME_SNAKE}_usecase.dart"
import 'package:core/packages/dartz/dartz.dart';
import 'package:core/usecase/usecase.dart';
import 'package:failures/failures.dart';
import '../../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
import '../../${MODULE_NAME_SNAKE}_repository/${MODULE_NAME_SNAKE}_repository.dart';

class ${FEATURE_NAME_PASCAL}UseCase
    implements UseCase<${FEATURE_NAME_PASCAL}Response, ${FEATURE_NAME_PASCAL}RequestModel> {
  final ${MODULE_NAME_PASCAL}Repository repository;
  ${FEATURE_NAME_PASCAL}UseCase({required this.repository});
  @override
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> call(${FEATURE_NAME_PASCAL}RequestModel params) async {
    return await repository.${FEATURE_NAME_SNAKE}(${FEATURE_NAME_SNAKE}Data: params);
  }
}
EOF
cat <<EOF > "$PRES_FEATURE_CUBIT_PATH/${FEATURE_NAME_SNAKE}_state.dart"
part of '${FEATURE_NAME_SNAKE}_cubit.dart';

class ${FEATURE_NAME_PASCAL}State extends BaseState {
  const ${FEATURE_NAME_PASCAL}State({this.failure, this.featureData, super.screenLoading = false});
  final Failure? failure;
  final ${FEATURE_NAME_PASCAL}Response? featureData;

  @override
  ${FEATURE_NAME_PASCAL}State copyWith({Failure? failure, bool? screenLoading, ${FEATURE_NAME_PASCAL}Response? featureData}) {
    return ${FEATURE_NAME_PASCAL}State(
      failure: failure ?? this.failure,
      screenLoading: screenLoading ?? this.screenLoading,
      featureData: featureData ?? this.featureData,
    );
  }
  @override
  List<Object?> get props => [screenLoading, failure, featureData];
}
EOF
cat <<EOF > "$PRES_FEATURE_CUBIT_PATH/${FEATURE_NAME_SNAKE}_cubit.dart"
import 'package:core/core.dart';
import 'package:core/packages/dartz/dartz.dart';
import 'package:failures/failures.dart';
import 'package:local_storage/local_storage.dart';
import '../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
import '../../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
import '../../../domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart';
part '${FEATURE_NAME_SNAKE}_state.dart';

class ${FEATURE_NAME_PASCAL}Cubit extends BaseCubit<${FEATURE_NAME_PASCAL}State> {
  final LocalStorage localStorage;
  final ${FEATURE_NAME_PASCAL}UseCase ${FEATURE_NAME_CAMEL}UseCase;
  ${FEATURE_NAME_PASCAL}Cubit(this.localStorage, this.${FEATURE_NAME_CAMEL}UseCase)
      : super(const ${FEATURE_NAME_PASCAL}State());
  @override
  Future<void> initState() async {}
  Future<void> get${FEATURE_NAME_PASCAL}() async {
    emit(state.copyWith(screenLoading: true));
    final Either<Failure, ${FEATURE_NAME_PASCAL}Response> response =
        await ${FEATURE_NAME_CAMEL}UseCase.call(${FEATURE_NAME_PASCAL}RequestModel());
    response.fold((failure) => emit(state.copyWith(failure: failure, screenLoading: false)), (data) => emit(state.copyWith(featureData: data, screenLoading: false)));
  }
}
EOF
cat <<EOF > "$BASE_PATH/presentation/Ui/screens/${FEATURE_NAME_SNAKE}_screen_view.dart"
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ui_components/ui_components.dart';
import '../../cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart';

class ${FEATURE_NAME_PASCAL}ScreenView extends BaseView<${FEATURE_NAME_PASCAL}Cubit> {
  static const String id = '/${FEATURE_NAME_PASCAL}ScreenView';
  const ${FEATURE_NAME_PASCAL}ScreenView({super.key});
  @override
  PreferredSizeWidget? appBar(BuildContext context) => AppBar(title: Text('${FEATURE_NAME_PASCAL} Screen'));
  @override
  Widget body(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.whiteColor, body: Center(child: Text('Content for ${FEATURE_NAME_PASCAL}ScreenView')));
  }
}
EOF
  echo "New files created."
  echo ""

  # --- Modify Existing Shared Files ---
  echo "Modifying shared module files to add '$FEATURE_NAME_SNAKE'..."
  
  # --- Define Anchors (as literal strings) ---
  ANCHOR_MODEL_IMPORT="// [Adding_new_model_import_here_dont_remove_this_command_!!!]"
  ANCHOR_REPO_METHOD="// [Adding_new_repo_method_here_dont_remove_this_command_!!!]"
  ANCHOR_REPO_IMPL_METHOD="// [Adding_new_repo_impl_method_here_dont_remove_this_command_!!!]"
  ANCHOR_DATASOURCE_METHOD="// [Adding_new_datasource_method_here_dont_remove_this_command_!!!]"
  ANCHOR_DATASOURCE_IMPL_METHOD="// [Adding_new_datasource_impl_method_here_dont_remove_this_command_!!!]"
  ANCHOR_DI_IMPORT="// [Adding_new_di_import_here_dont_remove_this_command_!!!]"
  ANCHOR_DI_DEPENDENCY="// [Adding_new_di_dependency_here_dont_remove_this_command_!!!]"
  ANCHOR_ROUTER_IMPORT="// [Adding_new_router_import_here_dont_remove_this_command_!!!]"
  ANCHOR_ROUTER_CASE="// [Adding_new_router_case_here_dont_remove_this_command_!!!]"
  ANCHOR_ROUTER_ID="// [Adding_new_router_screen_id_here_dont_remove_this_command_!!!]"

  # --- Prepare the new code blocks to be inserted ---

  # Imports
  NEW_MODEL_IMPORT_DOMAIN_REPO="import '../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';
  import '../../data/models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';"
  NEW_MODEL_IMPORT_DATA_FILES="import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request.dart';
  import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_response_model.dart';
  import '../models/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_request_model.dart';"
  NEW_DI_IMPORT="import '../domain/${MODULE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase/${FEATURE_NAME_SNAKE}_usecase.dart';
  import '../presentation/cubits/${FEATURE_NAME_SNAKE}/${FEATURE_NAME_SNAKE}_cubit.dart';"
  NEW_ROUTER_IMPORT="import 'presentation/Ui/screens/${FEATURE_NAME_SNAKE}_screen_view.dart';"

  # Method signatures and single lines
  NEW_REPO_METHOD="  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> ${FEATURE_NAME_SNAKE}({required ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data});"
  NEW_DATASOURCE_METHOD="  Future<${FEATURE_NAME_PASCAL}Response> ${FEATURE_NAME_SNAKE}(${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data);"
  NEW_DI_DEPENDENCY="..registerFactory(() => ${FEATURE_NAME_PASCAL}UseCase(repository: di()))
       ..registerFactory(() => ${FEATURE_NAME_PASCAL}Cubit(di(), di()))"
  NEW_SCREEN_ID="  static const String ${FEATURE_NAME_CAMEL}Screen = ${FEATURE_NAME_PASCAL}ScreenView.id;"

  # Multi-line repository implementation method
  read -r -d '' NEW_REPO_IMPL_METHOD << EOM
  @override
  Future<Either<Failure, ${FEATURE_NAME_PASCAL}Response>> ${FEATURE_NAME_SNAKE}(
      {required ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data}) async {
    try {
      final response = await authRemoteDataSource.${FEATURE_NAME_SNAKE}(${FEATURE_NAME_SNAKE}Data);
      return Right(response);
    } on Exception catch (error) {
      return Left(FailureHandler(error).getExceptionFailure());
    }
  }

EOM

  # Multi-line data source implementation method
  read -r -d '' NEW_DATASOURCE_IMPL_METHOD << EOM
  @override
  Future<${FEATURE_NAME_PASCAL}Response> ${FEATURE_NAME_SNAKE}(
      ${FEATURE_NAME_PASCAL}RequestModel ${FEATURE_NAME_SNAKE}Data) async {
    final apiRequest = ${FEATURE_NAME_PASCAL}Request(${FEATURE_NAME_SNAKE}Data);
    final result = await network.send(
      request: apiRequest,
      responseFromMap: (map) => ${FEATURE_NAME_PASCAL}Response.fromJson(map),
    );
    return result;
  }

EOM

  # Multi-line router case
  read -r -d '' NEW_ROUTE_CASE << EOM
      case ${FEATURE_NAME_PASCAL}ScreenView.id:
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const ${FEATURE_NAME_PASCAL}ScreenView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AppAnimations.slideAnimation(animation, child);
          },
        );
EOM

  # --- Use helper function to modify files ---

  # Modify Domain Repository Interface
  insert_before "$FILE_DOMAIN_MODULE_REPO" "$ANCHOR_MODEL_IMPORT" "$NEW_MODEL_IMPORT_DOMAIN_REPO"
  insert_before "$FILE_DOMAIN_MODULE_REPO" "$ANCHOR_REPO_METHOD" "$NEW_REPO_METHOD"
  echo "Updated: $FILE_DOMAIN_MODULE_REPO"
  
  # Modify Data Repository Implementation
  insert_before "$FILE_DATA_MODULE_REPO_IMPL" "$ANCHOR_MODEL_IMPORT" "$NEW_MODEL_IMPORT_DATA_FILES"
  insert_before "$FILE_DATA_MODULE_REPO_IMPL" "$ANCHOR_REPO_IMPL_METHOD" "$NEW_REPO_IMPL_METHOD"
  echo "Updated: $FILE_DATA_MODULE_REPO_IMPL"
  
  # Modify Remote Data Source
  insert_before "$FILE_DATA_MODULE_REMOTE_SOURCE" "$ANCHOR_MODEL_IMPORT" "$NEW_MODEL_IMPORT_DATA_FILES"
  insert_before "$FILE_DATA_MODULE_REMOTE_SOURCE" "$ANCHOR_DATASOURCE_METHOD" "$NEW_DATASOURCE_METHOD"
  insert_before "$FILE_DATA_MODULE_REMOTE_SOURCE" "$ANCHOR_DATASOURCE_IMPL_METHOD" "$NEW_DATASOURCE_IMPL_METHOD"
  echo "Updated: $FILE_DATA_MODULE_REMOTE_SOURCE"
  
  # Modify DI File
  insert_before "$FILE_DI_MODULE_MAIN" "$ANCHOR_DI_IMPORT" "$NEW_DI_IMPORT"
  insert_before "$FILE_DI_MODULE_MAIN" "$ANCHOR_DI_DEPENDENCY" "      $NEW_DI_DEPENDENCY"
  echo "Updated: $FILE_DI_MODULE_MAIN"
  
  # Modify Router File
  insert_before "$FILE_LIB_MODULE_ROUTER" "$ANCHOR_ROUTER_IMPORT" "$NEW_ROUTER_IMPORT"
  insert_before "$FILE_LIB_MODULE_ROUTER" "$ANCHOR_ROUTER_CASE" "$NEW_ROUTE_CASE"
  insert_before "$FILE_LIB_MODULE_ROUTER" "$ANCHOR_ROUTER_ID" "$NEW_SCREEN_ID"
  echo "Updated: $FILE_LIB_MODULE_ROUTER"
  
  echo ""
  echo "✅ New feature '$FEATURE_NAME_SNAKE' added successfully to module '$MODULE_NAME_SNAKE'."

else
  echo "Invalid choice. Exiting."
  exit 1
fi