Background

I have been using STM32CubeIDE for a while but I just can't get used to it, the IDE feels too slow (Eclipse is probably at fault here). This is why I have been looking for alternatives such as Visual Studio Code, which feels much faster. I tried a plugin, stm32-for-vscode, but did not convince me because any change applied to the DEBUG or optimizations flags in the Makefile are ignored, they are hardcoded in the extension.

This is why I decided to write a batch file (easier than a VSCode extension) that propagates the following items from the Makefile to the VSCode project configuration:
- Debug define
- Includes file list
- Defines list


Repository description

This repository contains a bat file that imports a STM32CubeMX generated Makefile into Visual Studio Code, meaning that some changes applied to the Makefile (those described in the previous bullet points) are imported into the c_cpp_properties.json, which is overwritten. On the other hand, the launch.json file is filled with a default configuration for debugging.

That way, if a user turns off the Debug flag (activates release mode), the .bat updates the preprocessor defines. Or, if a new header is included in the Makefile, the c_cpp_properties.json will also be updated, so that IntelliSense can show the correct information, no more unknown headers because only the makefile is updated. Same goes for unknown defines.

It is important to always keep the Makefile up to date, because it is the source of the VSCode project configuration. It has been designed like that so that the STM32 project can still be compiled without VSCode, just with make.

Some VSCode extensions are needed in order to develop with this text editor:
- Cortex-Debug extension
- C/C++ for Visual Studio Code

And even if VSCode is not used, the following programs are required to create/compile/debug a STM32 makefile project:
- STM32CubeMX
- ST-Link Drivers
- Make
- GNU Arm Embedded Toolchain
- OpenOCD


Usage

Copy the following files from this repository to the destination project, and overwrite the existing ones:
- update_vscode.bat
- tasks.json (copy it under the .vscode folder)

Inside VSCode, executing any task (Build, Build all, Clean) will also call the batch to update IntelliSense information and debug configuration. You can also execute "Import from Makefile" task if you only want to update the VSCode project information, it will not build or clean.

Also, you can optionally add the following lines after the list of C_DEFS in the makefile:
ifeq ($(DEBUG), 1)
C_DEFS += -DDEBUG
endif
The batch script accepts it because I like to add a DEBUG flag to the project.

Not related to this project, but the STM32CubeMX generated Makefile needs a line change if executed under Windows, in "clean" replace this:
	-rm -fR $(BUILD_DIR)
with this:
	if exist $(BUILD_DIR) (rmdir /Q /S $(BUILD_DIR))

A limitation of this project is that if you want to change the IntelliSense configuration, you have to edit the bat file, because it will overwrite the c_cpp_properties.json file.

Note: It is very probable that the launch.json part of the batch file will have to be customized depending on the target microcontroller. You should go to "OpenOCD-20200729-0.10.0\share\openocd\scripts\target" and find the required .cfg to be used. After that, update the batch script with it instead of the default "stm32g4x.cfg"

Dependencies

This project has been tested with the following resources:
- STM32CubeMX v6.1.0
- C/C++ for Visual Studio Code v1.1.2
- Cortex-Debug v0.3.7
- OpenOCD v0.10.0
- Make v3.81
- arm-none-eabi-gcc v9.3.1