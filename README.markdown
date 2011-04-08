# web.napopa.com's Bash Utilities
Currently there are mainly string and file manipulation functions. More will be added and then this notice will change.

## Utilities
Some functions output more ( such as information messages) that the required results. The result is then kept in **$RET** variable

* **isset** `var` - Checks if var is set
* *input_nonempty* `promptMsg` - Prompt the user to empty non empty var
* **replace_all** `string` `subject` `replacment`- Replace all occurencies of `subject` in `string`
* **replace_first** `string` `subject` `replacment`- Replace only the first occurence of `subject` in `string`
* **replace_string_line_containing** `string` `subject` `replacment`- Replace a whole line from `string` that contains `subject`
* **replace_file_line_containing** `filePath` `subject` `replacment`- Replace a whole line from the file at `filePath` that contains `subject`
* **replace_ini_entry** - See the source code for details. It replaces an entry in a .ini file while saving the inline comments in the end.
* **fix_ini_file_comments** `filePath` - Converts old style(#) to new style(;) .ini comments
* **strip_left_up_to** `string` `delimiter` - Removes all characters (starting from the left) from string up to the provided delimiter
* **strip_right_up_to** `string` `delimiter` - Removes all characters (starting from the right) from string up to the provided delimiter
* **trim_right** `string` `trimChars` - Trims provided characters from the right
* **update_PATH_entry** - CURRENTLY NOT WORKING
* **restart_apache**
* **input_two_choice** `question` `option1` `option2` (`default`) - Ask the user to answer question with one of two choices. If none of them is chosen and the default is not provided then the user is prompted again until a valid choice.
* **update_global_commands_paths** - CURRENTLY NOT WORKING Alias of update_PATH_entry
* **install_apt** `*` - Install applications provided as arguments using Aptitude
* **remove_apt** `*` - Removes applications provided as arguments using Aptitude
* **update_apt** `*` - Run Aptitude update
* **upgrade_apt** `*` - Run Aptitude upgrade
* **add_ppa_repository** `theRepositoryName` - Adds Aptitude reposisotry only by its name (no ppa:)
* **usage** `filePath` - Output usage information
* **debug_print** `*` - Prints provided parameters only if $DEBUG is true
* **debug_wait_for_enter** - Waits the user to press enter only if $DEBUG is true

### Directory Utilities
* **input_existing_dir** `inputPromptMsg` - Prompt the user to input a path to a directory. Then executes *get_existing_dir*
* **input_existing_dir_with_default** `defaultDirPath` `inputPromptMsg`- Prompt the user to input a path to a directory. If none provided the it's set to defaultDirPath. Then executes *get_existing_dir*
* **get_existing_dir** `dirPath` - Checks whether the provided dirPath is existing. Ask the user to input path to an existing dir. It keeps asking until such is provided
* **copy_dir_contents_to** `from` `to` - Copy the contents of a directory elsewhere
* **touch_dir** `dirPath` - Creates a directory. If some of the directory ancestors does not exist. It creates them as well.

### File Utilities
* **read_file** `filePath` - Loads an entire file into a variable. Access it in $RET variable.
* **get_existing_file_path** - Wait for filepath input. Checks whether such file exists and if it doesn't then asks the user to enter it until such file is found. Access the filename via $RET variable.
* **input_existing_file_path** `inputPromptMsg` - Prompts the user to enter a filepath. Checks whether such file exists and if it doesn't then asks the user to enter it until such file is found. Access the filename via $RET variable.
* **get_existing_file** `inputPromptMsg` - Prompts the user to enter a filepath. Checks whether such file exists and if it doesn't then asks the user to enter it until such file is found. Then reads the file into $RET variable.
* **get_file** `inputPromptMsg` - Prompts the user to enter a filepath. Will try to read the filepath into $RET no matter whether it is a valid file.
* **get_file_path_with_default** `defaultFilePath` `inputPromptMsg` - Prompts the user to enter a filepath. Checks whether such file exists and if it doesn't it return default provided filepath. Access the filename it via $RET variable.
* **get_file_with_default_path** `defaultFilePath` `inputPromptMsg` - Prompts the user to enter a filepath. Checks whether such file exists and if it doesn't it set the filepath to the default one provided. Then the file is read via **read_file**
* **overwrite_save_file** `filePath` `data` - Rewrites a file with a completely new content
* **overwrite_save_file** `filePath` `data`  - Append the provided datat to the current file content
* **make_symlink** `from` `to` - Generates a soft link
* **make_shortcut** `from` `to` - Alias of **make_symlink**
* **copy_file** `from` `to`