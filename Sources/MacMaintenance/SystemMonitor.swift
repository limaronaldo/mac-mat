import Darwin
import Foundation

enum SystemMonitor {
    // Helper for VM statistics
    private static let vm_kernel_page_size: Int = {
        var pagesize: Int = 0
        var len = MemoryLayout<Int>.size
        sysctlbyname("hw.pagesize", &pagesize, &len, nil, 0)
        return pagesize
    }()
    static func showStatus() {
        print("\n╔════════════════════════════════════════╗")
        print("║      MacBook Maintenance Status        ║")
        print("╚════════════════════════════════════════╝\n")

        // CPU Usage
        let cpuUsage = getCPUUsage()
        print("💻 CPU Usage: \(String(format: "%.1f", cpuUsage))%")

        // RAM Usage
        let (usedRAM, totalRAM) = getRAMUsage()
        let ramPercentage = (Double(usedRAM) / Double(totalRAM)) * 100
        print(
            "🧠 RAM Usage: \(Utils.formatBytes(usedRAM)) / \(Utils.formatBytes(totalRAM)) (\(String(format: "%.1f", ramPercentage))%)"
        )

        // Disk Usage
        if let (usedDisk, totalDisk) = getDiskUsage() {
            let diskPercentage = (Double(usedDisk) / Double(totalDisk)) * 100
            print(
                "💾 Disk Usage: \(Utils.formatBytes(usedDisk)) / \(Utils.formatBytes(totalDisk)) (\(String(format: "%.1f", diskPercentage))%)"
            )
        }

        // Battery Status
        if let battery = getBatteryStatus() {
            let icon = battery.isCharging ? "🔌" : "🔋"
            print(
                "\(icon) Battery: \(battery.percentage)%\(battery.isCharging ? " (Charging)" : "")")
        }

        // Uptime
        let uptime = getUptime()
        print("⏱️  Uptime: \(uptime)")

        print("\n⚠️  Top 3 CPU Hogs:")
        let topProcesses = getTopProcesses(limit: 3)
        for (index, process) in topProcesses.enumerated() {
            print("  \(index + 1).\(process.name) - \(String(format: "%.1f", process.cpu))%")
        }

        print()
        Logger.log("System status checked", level: .info)
    }

    static func showTopProcesses() {
        print("\n╔════════════════════════════════════════╗")
        print("║         Top CPU Processes             ║")
        print("╚════════════════════════════════════════╝\n")

        let topProcesses = getTopProcesses(limit: 10)
        print(String(format: "%-30s %8s %8s", "Process Name", "CPU %", "PID"))
        print(String(repeating: "-", count: 50))

        for process in topProcesses {
            print(String(format: "%-30s %7.1f%% %8d", process.name, process.cpu, process.pid))
        }
        print()
    }

    // MARK: - Private Helpers

    private static func getCPUUsage() -> Double {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/top")
        task.arguments = ["-bn1", "-l", "1"]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()

            guard let output = String(data: data, encoding: .utf8) else { return 0 }
            let lines = output.split(separator: "\n")

            for line in lines {
                if line.contains("CPU usage:") {
                    let components = line.split(separator: " ")
                    for (index, component) in components.enumerated() {
                        if component.contains("user") && index > 0 {
                            if let percentage = Double(
                                String(components[index - 1]).replacingOccurrences(
                                    of: "%", with: ""))
                            {
                                return percentage
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error getting CPU usage: \(error)")
        }

        return 0
    }

    private static func getRAMUsage() -> (Int64, Int64) {
        var stats = vm_statistics64_data_t()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let kerr = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(
                    mach_host_self(),
                    HOST_VM_INFO64,
                    $0,
                    &count)
            }
        }

        guard kerr == KERN_SUCCESS else { return (0, 0) }

        let usedMemory =
            Int64(stats.active_count + stats.inactive_count + stats.wire_count)
            * Int64(vm_kernel_page_size)
        let totalMemory = Int64(ProcessInfo.processInfo.physicalMemory)

        return (usedMemory, totalMemory)
    }

    private static func getDiskUsage() -> (Int64, Int64)? {
        let task = Process()
        task.launchPath = "/bin/df"
        task.arguments = ["-k", NSHomeDirectory()]

        let pipe = Pipe()
        task.standardOutput = pipe

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()

            guard let output = String(data: data, encoding: .utf8) else { return nil }
            let lines = output.split(separator: "\n")

            if lines.count > 1 {
                let components = lines[1].split(separator: " ").filter { !$0.isEmpty }
                if components.count >= 3,
                    let total = Int64(components[1]),
                    let available = Int64(components[3])
                {
                    let used = total - available
                    return (used * 1024, total * 1024)  // Convert to bytes
                }
            }
        } catch {
            print("Error getting disk usage: \(error)")
        }

        return nil
    }

    private static func getTopProcesses(limit: Int) -> [(name: String, cpu: Double, pid: Int32)] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/top")
        task.arguments = ["-bn1", "-o", "%CPU", "-l", "1"]

        let pipe = Pipe()
        task.standardOutput = pipe

        var processes: [(name: String, cpu: Double, pid: Int32)] = []

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()

            guard let output = String(data: data, encoding: .utf8) else { return processes }
            let lines = output.split(separator: "\n", omittingEmptySubsequences: true)

            var foundHeader = false
            for line in lines {
                if line.contains("PID") {
                    foundHeader = true
                    continue
                }

                if !foundHeader { continue }

                let components = line.split(separator: " ", omittingEmptySubsequences: true).map(
                    String.init)

                if components.count >= 12,
                    let pid = Int32(components[0]),
                    let cpu = Double(components[2])
                {
                    let name = components.last ?? "Unknown"
                    processes.append((name: name, cpu: cpu, pid: pid))

                    if processes.count >= limit {
                        break
                    }
                }
            }
        } catch {
            print("Error getting top processes: \(error)")
        }

        return processes
    }

    private static func getBatteryStatus() -> (percentage: Int, isCharging: Bool)? {
        let (exitCode, output) = Utils.executeCommand("/usr/bin/pmset", arguments: ["-g", "batt"])

        guard exitCode == 0 else { return nil }

        // Parse output like: "Now drawing from 'Battery Power' -InternalBattery-0 (id=1234)	85%; discharging; 3:45 remaining"
        let lines = output.split(separator: "\n")
        for line in lines {
            if line.contains("%") {
                let components = line.split(separator: "\t")
                if let percentageComponent = components.first(where: { $0.contains("%") }) {
                    let percentageStr = percentageComponent.split(separator: "%")[0]
                        .trimmingCharacters(in: .whitespaces)
                    if let percentage = Int(percentageStr) {
                        let isCharging = line.contains("charging") && !line.contains("discharging")
                        return (percentage, isCharging)
                    }
                }
            }
        }

        return nil
    }

    private static func getUptime() -> String {
        let (exitCode, output) = Utils.executeCommand("/usr/bin/uptime", arguments: [])

        guard exitCode == 0 else { return "Unknown" }

        // Parse output like: "10:30  up 5 days, 12:34, 3 users, load averages: 1.23 1.45 1.67"
        if let uptimeMatch = output.range(of: "up ([^,]+)", options: .regularExpression) {
            let uptimeStr = String(output[uptimeMatch]).replacingOccurrences(of: "up ", with: "")
            return uptimeStr.trimmingCharacters(in: .whitespaces)
        }

        return "Unknown"
    }
}
