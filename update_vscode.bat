@echo off
cls
setlocal ENABLEDELAYEDEXPANSION

set stm32_target=0
set stm32_debug=0
set in_includes=0
set in_defines=0
set c_cpp_props=.vscode\c_cpp_properties.json
set launch_props=.vscode\launch.json


for /F "tokens=* USEBACKQ" %%F in (`where arm-none-eabi-gcc.exe`) do (
	set gcc_path=%%F
	set gcc_path=!gcc_path:\=\\!
)
if "%gcc_path%"=="" (
	echo Error: arm-none-eabi-gcc not found, include its folder in Windows Path variable
	exit /b 1
)


if exist %c_cpp_props% (del %c_cpp_props%)
echo {>>"%c_cpp_props%"
echo     "configurations": [>>"%c_cpp_props%"
echo         {>>"%c_cpp_props%"
echo             "name": "STM32",>>"%c_cpp_props%"

for /F "eol=# tokens=1,3*" %%A in (Makefile) do (

	if "%%A"=="DEBUG" (
		set stm32_debug=%%B
	)

	if "%%A"=="TARGET" (
		set stm32_target=%%B
	)

	if "!in_includes!"=="1" (
		if "%%A"=="ASFLAGS" (
			set in_includes=0
			echo                 "">>"%c_cpp_props%"
			echo             ],>>"%c_cpp_props%"
		) else (
			set inc_name=%%A
			echo                 "!inc_name:~2!",>>"%c_cpp_props%"
		)
	)
	
	if "%%A"=="C_INCLUDES" (
		set in_includes=1
		echo             "includePath": [>>"%c_cpp_props%"
	)

	if "!in_defines!"=="1" (
		set res=F
		if "%%A"=="ifeq" (set res=T)
		if "%%A"=="AS_INCLUDES" (set res=T)
		if "!res!"=="T" (
    		set in_defines=2
			if "!stm32_debug!"=="1" (
				echo                 "DEBUG">>"%c_cpp_props%"
			) else (
				echo                 "">>"%c_cpp_props%"
			)
			echo             ],>>"%c_cpp_props%"
		) else (
			set def_name=%%A
			echo                 "!def_name:~2!",>>"%c_cpp_props%"
		)
	)

	if "%%A"=="C_DEFS" (
		if "!in_defines!"=="0" (
			set in_defines=1
			echo             "defines": [>>"%c_cpp_props%"
		)
	)

)

echo             "compilerPath": "%gcc_path%",>>"%c_cpp_props%"
echo             "cStandard": "c17",>>"%c_cpp_props%"
echo             "intelliSenseMode": "gcc-arm">>"%c_cpp_props%"
echo         }>>"%c_cpp_props%"
echo     ],>>"%c_cpp_props%"
echo     "version": 4 >>"%c_cpp_props%"
echo }>>"%c_cpp_props%"


if exist %launch_props% (del %launch_props%)
echo {>>"%launch_props%"
echo     "configurations": [>>"%launch_props%"
echo         {>>"%launch_props%"
echo             "showDevDebugOutput": false,>>"%launch_props%"
echo             "cwd": "${workspaceRoot}",>>"%launch_props%"
echo             "executable": "./build/!stm32_target!.elf",>>"%launch_props%"
echo             "name": "Debug STM32",>>"%launch_props%"
echo             "request": "launch",>>"%launch_props%"
echo             "type": "cortex-debug",>>"%launch_props%"
echo             "servertype": "openocd",>>"%launch_props%"
echo             "preLaunchTask": "Build",>>"%launch_props%"
echo             "device": "stlink",>>"%launch_props%"
echo             "configFiles": [>>"%launch_props%"
echo                 "interface/stlink.cfg",>>"%launch_props%"
echo                 "target/stm32g4x.cfg">>"%launch_props%"
echo             ]>>"%launch_props%"
echo         }>>"%launch_props%"
echo     ]>>"%launch_props%"
echo }>>"%launch_props%"


echo Finished importing from Makefile