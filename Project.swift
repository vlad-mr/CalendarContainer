import ProjectDescription
import ProjectDescriptionHelpers

let bundleId = "io.full.CalendarContainer"
let deploymentTarget = DeploymentTarget.iOS(targetVersion: "13.0", devices: .iphone)

let settings = Settings(
    configurations: [
        .debug(name: "Debug", settings: debugSettings),
        .release(name: "Beta", settings: betaSettings),
        .release(name: "Release", settings: releaseSettings),
    ]
)

// MARK: - Calendar Kit

let calendar = Project.makeFrameworkTargets(
    name: "UI",
    platform: .iOS,
    appBundleId: bundleId,
    deploymentTarget: deploymentTarget,
    settings: settings,
    dependencies: [
        .target(name: "AnywhereCalendarSDK"),
    ]
)

// MARK: - Interface

let interface = Project.makeFrameworkTargets(
    name: "AnywhereInterfaceModule",
    platform: .iOS,
    appBundleId: bundleId,
    deploymentTarget: deploymentTarget,
    settings: settings,
    dependencies: [
    ]
)

// MARK: - API

let schedulingEngine = Project.makeFrameworkTargets(
    name: "AnywhereSchedulingEngineModule",
    platform: .iOS,
    appBundleId: bundleId,
    deploymentTarget: deploymentTarget,
    settings: settings,
    dependencies: [
        .target(name: "AnywhereInterfaceModule"),
    ],
    coreDataModels: [
        CoreDataModel("AnywhereEvents.xcdatamodeld"),
    ]
)

// MARK: - Event View

let eventView = Project.makeFrameworkTargets(
    name: "AnywhereAppointmentModule",
    platform: .iOS,
    appBundleId: bundleId,
    deploymentTarget: deploymentTarget,
    settings: settings,
    dependencies: [
        .target(name: "AnywhereInterfaceModule"),
    ]
)

// MARK: - Calendar Components

let components = Project.makeFrameworkTargets(
    name: "AnywhereCalendarSDK",
    platform: .iOS,
    appBundleId: bundleId,
    deploymentTarget: deploymentTarget,
    settings: settings,
    dependencies: [
    ]
)

// MARK: - Main

let main = Target(
    name: "CalendarContainer",
    platform: .iOS,
    product: .app,
    productName: "CalendarContainer",
    bundleId: bundleId,
    deploymentTarget: deploymentTarget,
    infoPlist: .default,
    sources: ["Targets/CalendarContainer/Sources/**"],
    resources: ["Targets/CalendarContainer/Resources/**"],
    dependencies: [
        .cocoapods(path: "."),
    ],
    settings: settings
)

let tests = Target(
    name: "CalendarContainerTests",
    platform: .iOS,
    product: .unitTests,
    bundleId: bundleId + ".CalendarContainerTests",
    infoPlist: .default,
    sources: ["Targets/CalendarContainer/Tests/**"],
    dependencies: [
        .target(name: "CalendarContainer"),
        .xctest,
    ]
)

// MARK: - Targets

func makeTargets() -> [Target] {
    var targets: [Target] = [main, tests]
    //  targets.append(contentsOf: eventView)
    //  targets.append(contentsOf: schedulingEngine)
    //  targets.append(contentsOf: components)
    //  targets.append(contentsOf: interface)
    return targets
}

// MARK: - Project

let project = Project(
    name: "CalendarContainer",
    organizationName: "Anywhere",
    targets: makeTargets()
)

// MARK: - Settings

let debugSettings = SettingsDictionary()
    .swiftVersion("5.5")
    .automaticCodeSigning(devTeam: "FQ2VH4S3H2")

let betaSettings = SettingsDictionary()
    .swiftVersion("5.5")
    .bitcodeEnabled(true)
    .swiftCompilationMode(.wholemodule)
    .automaticCodeSigning(devTeam: "FQ2VH4S3H2")

let releaseSettings = SettingsDictionary()
    .swiftVersion("5.5")
    .bitcodeEnabled(true)
    .swiftCompilationMode(.wholemodule)
    .automaticCodeSigning(devTeam: "FQ2VH4S3H2")
