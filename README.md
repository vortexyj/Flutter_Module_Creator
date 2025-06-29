# Flutter Module & Feature Scaffolding Script (`create_flutter_module_and_feature.sh`)

This script automates the creation of a new Flutter module (as a separate package) and scaffolds an initial feature structure within it. The generated structure follows our team's preferred clean architecture conventions.

## 1. What This Script Does

This script will:
* Create a new Flutter package for your module using `flutter create --template=package [ModuleName]`.
* Set up standard clean architecture layers:
    * **Data Layer:** Models, repository implementations, remote data source.
    * **Domain Layer:** Repository interfaces, use cases.
    * **Presentation Layer:** Cubits, states, screen views (UI).
* Include boilerplate for:
    * Dependency Injection (DI) setup using GetIt.
    * Basic screen routing for the module.
* Customize generated code based on two inputs: a **Module Name** and a **Feature Name**.

This aims to save significant boilerplate time and ensure consistency across new modules.

## 2. Prerequisites

Before using this script, ensure you have:

* **macOS:** This guide and script have been developed and tested on macOS.
* **Flutter SDK:** Installed and correctly configured in your system's `PATH`. You should be able to run `flutter doctor` in your terminal without issues.
* **Zsh Shell:** This is the default shell on newer macOS versions. The setup instructions use `~/.zshrc` for configuration.
    * **Note for Bash users:** If you use Bash, you'll need to edit `~/.bash_profile` or `~/.bashrc` instead of `~/.zshrc`. The `export PATH` command itself is the same.

## 3. One-Time Setup (To Run the Script from Anywhere)

To make the script easily accessible from any location in your terminal, follow these one-time setup steps on your Mac.

### 3.1. Get the Script
* Obtain the `create_flutter_module_and_feature.sh` file. (This `README.md` should ideally be in the same repository or location as the script).

### 3.2. Create a Personal Scripts Folder
This is a standard place to keep your command-line scripts.
1.  Open **Terminal**.
2.  Type:
    ```bash
    mkdir -p ~/bin
    ```
    *(The `-p` flag ensures it doesn't show an error if the folder already exists).*

### 3.3. Move the Script into `~/bin`
1.  Assuming the script `create_flutter_module_and_feature.sh` is in the current directory (e.g., you've cloned this repository), type in Terminal:
    ```bash
    mv create_flutter_module_and_feature.sh ~/bin/
    ```
    *(If it's elsewhere, adjust the source path accordingly).*

### 3.4. Make the Script Executable
1.  In Terminal, type:
    ```bash
    chmod +x ~/bin/create_flutter_module_and_feature.sh
    ```

### 3.5. Add Your `~/bin` Folder to Your Shell's `PATH`
This allows your terminal to find the script.
1.  In Terminal, type:
    ```bash
    nano ~/.zshrc
    ```
2.  Use the arrow keys to scroll to the very **end** of the file.
3.  Add the following exact line as a new line at the end:
    ```
    export PATH="$HOME/bin:$PATH"
    ```
4.  **Save and Exit `nano`**:
    * Press `Ctrl + O` (the letter "O").
    * Press `Enter` (to confirm the filename).
    * Press `Ctrl + X` (to exit nano).

### 3.6. Apply the `PATH` Changes
For the changes to take effect:
* **EITHER** close your current Terminal window completely and open a brand new one.
* **OR** in your existing Terminal window, type:
    ```bash
    source ~/.zshrc
    ```

## 4. How to Use the Script

Once the one-time setup is complete:

1.  **Open Terminal.**
2.  **Navigate to Your Projects Directory:**
    Use the `cd` command to go to the parent folder where you want your *new module's folder* to be created.
    * **Example:** If you want to create modules inside `~/development/my_apps/packages/`, type:
        ```bash
        cd ~/development/my_apps/packages/
        ```
3.  **Run the Script:**
    Simply type the script's name:
    ```bash
    create_flutter_module_and_feature.sh
    ```
4.  **Follow the Prompts:**
    * **Prompt 1 (Module Name):**
        `Enter the name for the new Flutter Module (package, snake_case, e.g., auth_service):`
        Type your desired module name (e.g., `user_profile_service`) and press Enter. **Use `snake_case`** (all lowercase, words separated by underscores).
    * **Prompt 2 (Feature Name):**
        `Enter the specific FEATURE name for the initial feature within '[YourModuleName]' (e.g., user_login, product_details):`
        Type your desired feature name (e.g., `view_details` or `edit_form`) and press Enter. **Use `snake_case`**.
5.  **Script Execution:**
    The script will create a new folder with your module name in the current directory. Inside that, it will generate a `lib/` directory filled with the clean architecture structure for your specified module and feature.

## 5. Quick Troubleshooting

* **`zsh: command not found: create_flutter_module_and_feature.sh`**
    * **Likely Cause:** Terminal session hasn't picked up `PATH` changes.
    * **Fix:** Close ALL terminal windows and open a new one. Or, run `source ~/.zshrc` in your current terminal.
    * Verify you completed all steps in "3. One-Time Setup".
    * Check if `create_flutter_module_and_feature.sh` is in `~/bin` (`ls -l ~/bin`).
    * Ensure no typos in the script name when running.

* **`flutter: command not found` (error from the script)**
    * Your Flutter SDK isn't correctly installed or configured in your system's PATH. Run `flutter doctor`. If it fails, fix your Flutter setup.

* **`Error: A directory named '[ModuleName]' already exists here.`**
    * A folder with the module name you entered already exists. Delete/move it or choose a different name.

* **Permission errors when running the script:**
    * You might have missed Step 3.4 (`chmod +x ...`). Re-run it on `~/bin/create_flutter_module_and_feature.sh`.

## 6. What Gets Created (Brief Overview)

The script creates a new Flutter package (your module). Inside its `lib` folder, you'll find:
* **`data/`**:
    * `models/[feature_name]/` (for `_request.dart`, `_request_model.dart`, `_response_model.dart`)
    * `[module_name]_repository/` (repository implementation)
    * `remote_data_source/` (`[module_name]_remote_data_source.dart`)
* **`domain/`**:
    * `[module_name]_repository/` (repository interface)
    * `[module_name]_usecase/[feature_name]_usecase/` (`[feature_name]_usecase.dart`)
* **`presentation/`**:
    * `Ui/screens/[feature_name]_screen_view.dart`
    * `cubits/[feature_name]/` (`[feature_name]_cubit.dart`, `[feature_name]_state.dart`)
* **`di/`**: `[module_name]_di.dart` for GetIt dependency setup.
* **Root of `lib/`**:
    * `[module_name].dart` (exports the module's router)
    * `[module_name]_screen_router.dart` (basic screen router)

Many generated Dart files include `// TODO:` comments to guide you on where to add your specific logic.

## 7. Contributing / Further Development (Optional)

* Ideas for improvements are welcome.
* Feel free to fork this repository, make changes, and open a Pull Request.
* Ensure any changes to the script are tested.
* Update this `README.md` if script functionality changes.

---
