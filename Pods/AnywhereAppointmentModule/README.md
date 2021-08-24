# Anywhere-IOS-Module

This repository consists of various modules used in Anywhere projects.


 ## Steps to create a module
 
 - Go to File -> New -> Target -> Framework.
 - Update the name of the framework, select `Include Tests` and create.
 - Create new folder named `Sources` in framework target and drag & drop all the files under that target to this folder.
 - Create another folder named `Tests` in framework target and drag & drop the folder for test target to this folder.
 - Update the `info.plist` path in `build setting` for both framework and test target.
 - Try to run the tests for the newly created framework to verify that the configuration is done correctly.
 - SwiftLint: Create runscript under Build Settings with the following script 
    ```swift
    if which "${PODS_ROOT}/SwiftLint/swiftlint" >/dev/null; then
    ${PODS_ROOT}/SwiftLint/swiftlint
    else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
    fi
   ```
 - Enable SwiftLint:  Add `PluginName` under .swiftlint.yml file for following codestandards. 

## Steps to create a submodule
 
 - Go to the podspec of the module to which you would like to add the submodule
 - Add a subspec with the name of the submodule
 - Create new folder with the name of submodule under `Sources` in framework target and drag & drop all the files under that target to this folder.
 - Update the source_files of the submodule to the newly created folder in podspec file
 - Add your submodule as a dependency to the core module in the podspec
 - Try to lint your podspec to verify that the configuration is done correctly.

## Steps to deploy a new module
 
 - Add a new framework, refer to the [step to create a module](https://github.com/Adaptavant/Anywhere-IOS-Module/blob/main/README.md#steps-to-create-a-module).
 - Add a README.md file under the your pod folder and please be consistent in readme template with other services
 - Update the source code.
 - Commit the changes and tag the changes in the following format.
 - `git tag "{PluginName}/1.0.0"` and push `git push origin "{PluginName}/1.0.0"`
 - `pod spec create {PluginName}` create new podspec manually by this command 
 - Deploy your pod in [ios-podspecs](https://github.com/Adaptavant/ios-podspecs) by following the steps mentioned there.
 Note: Deployment of submodules will depend on the deployment of the main module.
  
 ## References
 
 - [Create and Manage Private Cocoapods](https://medium.com/@kvikas877/create-and-manage-private-cocoapods-in-swift-2f2031e16c1a)
 - [Cocoapods Under the Hood](https://www.objc.io/issues/6-build-tools/cocoapods-under-the-hood/)
 - [Cocoapods creation with framework](https://betterprogramming.pub/ios-build-your-cocoapods-framework-with-an-example-app-from-scratch-fd0f7bdf3f8c)
