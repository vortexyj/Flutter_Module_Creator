#!/usr/bin/env ruby

# This Ruby script generates the README.md file for the project.
# It contains the full documentation as a multi-line string (heredoc).

readme_content = <<~MARKDOWN
# Flutter Module & Feature Scaffolding Script

This script automates the creation of a new Flutter module (as a separate package) and scaffolds feature structures within it. The generated structure follows our team's preferred clean architecture conventions.

## 1. What This Script Does

The script runs in one of two modes:

* **Mode 1: Create a New Module:**
    * Creates a new Flutter package for your module using `flutter create --template=package`.
    * Scaffolds the initial feature, setting up standard clean architecture layers (Data, Domain, Presentation).
    * Includes boilerplate for Dependency Injection (DI) with GetIt and basic screen routing.
* **Mode 2: Add a New Feature:**
    * Adds a complete feature structure to an existing, previously generated module.
    * Intelligently updates shared files (router, repository, DI) to integrate the new feature.

This aims to save significant boilerplate time and ensure consistency across all modules and features.

## 2. Prerequisites

Before using this script, ensure you have:

* **macOS or a Linux-based environment:** The script uses bash and standard command-line tools (`mkdir`, `mv`, `awk`, `grep`).
* **Flutter SDK:** Installed and correctly configured in your system's `PATH`. You should be able to run `flutter doctor` in your terminal without issues.
* **A Unix-like Shell (zsh, bash):** The setup instructions use `~/.zshrc` (for zsh, the default on modern macOS), but can be adapted for `~/.bash_profile` or `~/.bashrc`.

## 3. One-Time Setup (To Run the Script from Anywhere)

To make the script easily accessible from any location in your terminal, follow these one-time setup steps.

### 3.1. Get the Script
* Obtain the script file. Let's assume it's named `flutter_scaffold.sh`.

### 3.2. Create a Personal Scripts Folder
This is a standard place to keep your command-line scripts.
1.  Open **Terminal**.
2.  Type:
    ```bash
    mkdir -p ~/bin
    ```

### 3.3. Move the Script into `~/bin`
1.  Assuming the script `flutter_scaffold.sh` is in your current directory, type in Terminal:
    ```bash
    mv flutter_scaffold.sh ~/bin/
    ```

### 3.4. Make the Script Executable
1.  In Terminal, type:
    ```bash
    chmod +x ~/bin/flutter_scaffold.sh
    ```

### 3.5. Add Your `~/bin` Folder to Your Shell's `PATH`
This allows your terminal to find the script by name.
1.  In Terminal, type the following to open your shell's configuration file:
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

The script has two main workflows.

### Mode 1: Creating a New Module and its First Feature

Use this when starting a brand new module.

1.  **Open Terminal.**
2.  **Navigate to Your Main Packages Directory:**
    Use `cd` to go to the parent folder where you want your *new module's folder* to be created.
    * **Example:** `cd ~/development/my_app/packages/`
3.  **Run the Script:**
    Simply type the script's name:
    ```bash
    flutter_scaffold.sh
    ```
4.  **Follow the Prompts:**
    * **Prompt 1 (Mode Selection):** Choose option `1`.
    * **Prompt 2 (Module Name):** Enter your module name (e.g., `user_profile`). **Use `snake_case`**.
    * **Prompt 3 (Feature Name):** Enter the name for the first feature (e.g., `view_details`). **Use `snake_case`**.
5.  **Script Execution:**
    The script will create and set up a complete module folder in your current directory.

### Mode 2: Adding a Feature to an Existing Module

Use this when you want to add a new feature to a module you have already created.

1.  **Open Terminal.**
2.  **Navigate INSIDE Your Existing Module's Directory:**
    Use `cd` to go into the root folder of the module you want to modify. This folder must contain the `pubspec.yaml` and `lib` directory.
    * **Example:** `cd ~/development/my_app/packages/user_profile/`
3.  **Run the Script:**
    ```bash
    flutter_scaffold.sh
    ```
4.  **Follow the Prompts:**
    * **Prompt 1 (Mode Selection):** The script will detect it's inside a module and automatically ask you to choose a mode. Select option `2`.
    * **Prompt 2 (Feature Name):** Enter the name for the **new** feature (e.g., `change_password`). **Use `snake_case`**.
5.  **Script Execution:**
    The script will create all the necessary files for the new feature and will also **modify existing shared files** (like the router, repository, and DI files) to include the new feature's boilerplate.

## 5. Quick Troubleshooting

* **`zsh: command not found: flutter_scaffold.sh`**
    * **Fix:** The `PATH` changes haven't been applied. Close and reopen your terminal, or run `source ~/.zshrc`. Verify all steps in "3. One-Time Setup" were completed.
* **`flutter: command not found` (error from within the script)**
    * **Fix:** Your Flutter SDK isn't correctly installed or configured. Run `flutter doctor` and fix your Flutter setup.
* **`Error: A directory named '[ModuleName]' already exists here.`**
    * **Fix:** You are trying to create a module in a location where a folder with that name already exists. Delete/move it or choose a different name.
* **Permission errors when running the script:**
    * **Fix:** You might have missed Step 3.4 (`chmod +x ...`). Re-run it.

## 6. What Gets Created (Brief Overview)

The script creates a standard folder structure within the module's `lib` directory:
* **`data/`**:
    * `models/[feature_name]/` (Request/Response models)
    * `[module_name]_repository/` (Repository implementation)
    * `remote_data_source/` (Remote data source implementation)
* **`domain/`**:
    * `[module_name]_repository/` (Repository interface)
    * `[module_name]_usecase/[feature_name]_usecase/` (Usecase for the feature)
* **`presentation/`**:
    * `Ui/screens/[feature_name]_screen_view.dart`
    * `cubits/[feature_name]/` (Cubit and State files)
* **`di/`**: The dependency injection setup file for the module.
* **Root of `lib/`**: The module's main export file and router file.

When running in **Mode 2**, the script not only creates the new files for the feature but also programmatically adds the necessary code for the new feature into the shared repository, data source, DI, and router files.

## 7. Contributing / Further Development

* Ideas for improvements are welcome.
* Feel free to fork this repository, make changes, and open a Pull Request.
* Ensure any changes to the script are tested.
* Update this `README.md` if script functionality changes.
MARKDOWN

# Write the content to a README.md file in the current directory
File.write("README.md", readme_content)

puts "✅ README.md file has been created successfully."
