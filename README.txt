Background

I have been using STM32CubeIDE for a while but I just can't get used to it, the IDE feels too slow (Eclipse is probably at fault here). This is why I have been looking for alternatives such as Visual Studio Code, which feels much faster. I tried a plugin, stm32-for-vscode, but did not convince me because any change applied to the DEBUG or optimizations flags in the Makefile are ignored, they are hardcoded in the extension.

This is why I decided to write a batch file (easier than a VSCode extension) that propagates the following items from the Makefile to the VSCode project configuration:
- Debug flag
- Optimization flag
- Includes file list
- Defines list


Repository description

This repository contains a bat file that imports a STM32CubeMX generated Makefile into Visual Studio Code, meaning that some changes applied to the Makefile (those described in the previous bullet points) are imported into the c_cpp_properties.json and launch.json files, which are overwritten.

That way, if a user turns off the Debug flag (activates release mode), the .bat updates the debugging profile and preprocessor definitions. Or, if a new include is inserted in the Makefile, the c_cpp_properties.json will also be updated, so that Intellisense can show the correct information, no more unknown headers because only the makefile is updated. Same goes for unknown defines.

It is important to always keep the Makefile up to date, because it is the source of the VSCode project configuration. It has been designed like that so that the STM32 project can still be compiled without VSCode, just with make.

Some VSCode extensions are needed in order to develop with this text editor:
- Cortex-Debug extension
- C/C++ for Visual Studio Code

And even if VSCode is not used, the following programs are required to compile/debug a STM32 makefile project:
- STM32CubeMX
- ST-Link Drivers
- Make
- GNU Arm Embedded Toolchain
- OpenOCD


Usage

Copy the following files from this repository to the destination project, and overwrite the existing ones:
- update_vscode.bat
- tasks.json

Inside VSCode, executing any task (Build, Build all, Clean) will also call the batch to update Intellisense information and debug configuration. You can also execute "Import from Makefile" task if you only want to update the VSCode project information, it will not build or clean.

Remember that STM32CubeMX needs to generate a Makefile project, other IDE projects are not valid.

Also, remember to add the following lines after the list of C_DEFS in the makefile
ifeq ($(DEBUG), 1)
C_DEFS += -DDEBUG
endif
The batch script expects it because I like to add a DEBUG flag to the project

Not related to this project, but the STM32CubeMX generated Makefile needs a line change if executed under Windows, in "clean" replace this:
	-rm -fR $(BUILD_DIR)
with this:
	rmdir /S /Q $(BUILD_DIR)

A limitation of this project is that if you want to change the Intellisense configuration, you have to edit the bat file, because it will overwrite the c_cpp_properties.json file


Dependencies

This project has been tested with the following resources:
- STM32CubeMX v6.1.0
- C/C++ for Visual Studio Code v1.1.2
- Cortex-Debug v0.3.7
- OpenOCD v0.10.0
- Make v3.81
- arm-none-eabi-gcc 9.3.1