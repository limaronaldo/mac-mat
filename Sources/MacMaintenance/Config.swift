import Foundation

struct Config: Codable {
    var cleanup: CleanupSettings
    var monitoring: MonitoringSettings
    var processesToMonitor: [String]

    struct CleanupSettings: Codable {
        var autoBackup: Bool
        var confirmBeforeDelete: Bool
        var maxCacheAgeDays: Int

        enum CodingKeys: String, CodingKey {
            case autoBackup = "auto_backup"
            case confirmBeforeDelete = "confirm_before_delete"
            case maxCacheAgeDays = "max_cache_age_days"
        }
    }

    struct MonitoringSettings: Codable {
        var cpuAlertThreshold: Int
        var ramAlertThreshold: Int
        var diskAlertThreshold: Int

        enum CodingKeys: String, CodingKey {
            case cpuAlertThreshold = "cpu_alert_threshold"
            case ramAlertThreshold = "ram_alert_threshold"
            case diskAlertThreshold = "disk_alert_threshold"
        }
    }

    enum CodingKeys: String, CodingKey {
        case cleanup
        case monitoring
        case processesToMonitor = "processes_to_monitor"
    }

    static let defaultConfig = Config(
        cleanup: CleanupSettings(
            autoBackup: true,
            confirmBeforeDelete: true,
            maxCacheAgeDays: 30
        ),
        monitoring: MonitoringSettings(
            cpuAlertThreshold: 80,
            ramAlertThreshold: 85,
            diskAlertThreshold: 90
        ),
        processesToMonitor: [
            "fileproviderd",
            "coredns",
            "mdworker",
            "bird",
            "cloudd"
        ]
    )

    static var shared: Config = {
        if let config = Config.load() {
            return config
        } else {
            let config = Config.defaultConfig
            config.save()
            return config
        }
    }()

    static func load() -> Config? {
        let configPath = "\(NSHomeDirectory())/.mac-maintenance/config.json"

        guard FileManager.default.fileExists(atPath: configPath) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let decoder = JSONDecoder()
            return try decoder.decode(Config.self, from: data)
        } catch {
            Logger.log("Failed to load config: \(error)", level: .warning)
            return nil
        }
    }

    func save() {
        let configDir = "\(NSHomeDirectory())/.mac-maintenance"
        let configPath = "\(configDir)/config.json"

        // Create directory if needed
        if !FileManager.default.fileExists(atPath: configDir) {
            try? FileManager.default.createDirectory(atPath: configDir, withIntermediateDirectories: true)
        }

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(self)
            try data.write(to: URL(fileURLWithPath: configPath))
            Logger.log("Config saved to \(configPath)", level: .info)
        } catch {
            Logger.log("Failed to save config: \(error)", level: .error)
        }
    }

    static func printConfig() {
        let config = Config.shared
        print("\n⚙️  Current Configuration\n")
        print("Cleanup Settings:")
        print("  Auto Backup: \(config.cleanup.autoBackup)")
        print("  Confirm Before Delete: \(config.cleanup.confirmBeforeDelete)")
        print("  Max Cache Age: \(config.cleanup.maxCacheAgeDays) days\n")
        print("Monitoring Thresholds:")
        print("  CPU Alert: \(config.monitoring.cpuAlertThreshold)%")
        print("  RAM Alert: \(config.monitoring.ramAlertThreshold)%")
        print("  Disk Alert: \(config.monitoring.diskAlertThreshold)%\n")
        print("Monitored Processes:")
        for process in config.processesToMonitor {
            print("  • \(process)")
        }
        print("\n📁 Config file: ~/.mac-maintenance/config.json\n")
    }
}
