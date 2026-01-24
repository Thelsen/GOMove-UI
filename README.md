An updated GOMove UI for TrinityCore 3.3.5a. Originally created by rochet2 https://github.com/Rochet2/TrinityCore/tree/gomove_3.3.5/src/server/scripts/Custom/GOMove

This has two new features:
1. 'Info' button that gives information about the selected gameobject
2. 'Pitch' and 'Roll' sliders that allow you to change the gameobject's pitch and roll (also works with mousewheel for fine-tuning)

To install this:
1. Place the GOMove folder in <WoW Installation Folder>\Interface\Addons
2. Place the GOMove.cpp, GOMoveScripts.cpp, and GOMove.h files in a <Trinity Installation Folder>\src\server\scripts\Custom\GOMove folder
3. Update your custom_script_loader.cpp file to reference the new custom script
4. Build your Trinity server with CMake
5. Build your Trinity visual studio solution
6. Login and type /gomove to open the UI (should be open by default)
