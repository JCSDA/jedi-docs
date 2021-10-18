## Debugging C++ JEDI applications using Visual Studio Code on MacOS

### Installing and preparing Visual Studio Code
1. Complete, at minimum, the "Prerequisites" section of [this documentation](https://code.visualstudio.com/docs/cpp/config-clang-mac). (Creating the HelloWorld application is optional.)
2. [Follow these instructions](https://code.visualstudio.com/docs/setup/mac) to add VS Code to your PATH so that you can launch it from the command line.
3. If unfamiliar with VS Code, you may want to [read some documentation](https://code.visualstudio.com/docs/).
4. Close VS Code for now.

### Prepare a debug build of the JEDI application you wish to debug
1. [Install the jedi-stack on your Mac](https://github.com/JCSDA-internal/jedi-docs/blob/develop/howto/macos/minimum.md) using the clang-mpich configuration.
2. [Build the bundle](https://jointcenterforsatellitedataassimilation-jedi-docs.readthedocs-hosted.com/en/latest/using/building_and_running/building_jedi.html) containing the application you wish to debug in debug mode. (Be sure to include the `--build=debug` option for the `ecbuild` command.)

### Set up the VS Code launch.json file
1. In a console, `cd` to the build directory where you built your JEDI application, then launch VS Code with the command `code .` (Launching VS Code in this way sets its `workspaceFolder` environment variable to the build directory.)
2. Select the `Run` icon in the Activity Bar on the left side of VS Code. (The icon containing a picture of a small bug.)
3. In the pane that appears, select the link that says `create a launch.json file`.
4. When prompted to select the environment, choose `C++ (GDB/LLDB)`.
5. You will need to edit at least three of the [launch.json attributes](https://code.visualstudio.com/docs/editor/debugging#_launchjson-attributes) in the generated `launch.json` file to reflect the application you wish to debug:
- **program**: the executable to run
- **args**: arguments to the executable (If unsure what values to use for `program` and `args`, look at the `command` recorded near the beginning of the test log of a relevant ctest.)
- **cwd**: Current working directory. Used as the relative path for other files the executable may read or write.
6. You might also want to change the `stopAtEntry` option to `true`.

As an example, here is a `launch.json` file which will debug the `test_qg_variable_change` ctest for the QG model in the OOPS repository:
```
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(lldb) Launch",
            "type": "cppdbg",
            "request": "launch",
            "program": "${workspaceFolder}/oops/qg/test/test_qg_variable_change",
            "args": ["${workspaceFolder}/oops/qg/test/testinput/interfaces.yaml"],
            "stopAtEntry": true,
            "cwd": "${workspaceFolder}/oops/qg/test",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb"
        }
    ]
}
```

### Debug the application
1. Before starting to debug, you might want to [set a breakpoint](https://code.visualstudio.com/docs/editor/debugging#_breakpoints) at the beginning of the section of code you wish to debug. You can open the desired source file with `File...Open` from the VS Code menu. Setting an initial breakpoint is especially important if you did not set `stopAtEntry` to `true` in the `launch.json` file. Be sure to open the source file from the code directory that was used to create the build.
2. You're ready to press `F5` to start debugging.
3. Refer to the [VS Code debugging documentation](https://code.visualstudio.com/docs/editor/debugging) if unfamiliar with graphical debuggers.

**Note:** Debugging Fortran code in this way is not supported. It will sort of step through the code, but it will not display variable values.