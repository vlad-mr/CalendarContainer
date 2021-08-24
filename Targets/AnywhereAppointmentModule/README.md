# AnywhereAppointmentModule

This module consists of the flows and various submodules related to Appointments.


## Steps to create a submodule
 
 - Go to AnywhereAppointmentModule.podspec
 - Add a subspec with the name of the submodule
 - Create new folder with the name of submodule under `Sources` in framework target and drag & drop all the files under that target to this folder.
 - Update the `source_files` of the submodule to the newly created folder in podspec file
 - Add your submodule as a dependency to the core module in the podspec
 - Try to lint your podspec to verify that the configuration is done correctly.
