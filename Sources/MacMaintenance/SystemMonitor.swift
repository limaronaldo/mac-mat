import Foundation

enum SystemMonitor {
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
        print("🧠 RAM Usage: \(formatBytes(usedRAM)) / \(formatBytes(totalRAM)) (\(String(format: "%.1f", ramPercentage))%)")
        
        // Disk Usage
        if let (usedDisk, totalDisk) = getDiskUsage() {
            let diskPercentage = (Double(usedDisk) / Double(totalDisk)) * 100
            print("💾 Disk Usage: \(formatBytes(usedDisk)) / \(formatBytes(totalDisk)) (\(String(format: "%.1f", diskPercentage))%)")
        }
        
        print("\n⚠️  Top 3 CPU Hogs:")
        let topProcesses = getTopProcesses(limit: 3)
        for (index, process) in topProcesses.enumerated() {
            print("  \(index + 1).  \(process.name) - \(String(format: "%.1f", process.cpu))%")
        }
        
        print()
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
        task.launchPath = "/usr/bin/top"
        task.arguments = ["-bn1", "-l", "1"]
        
        let pipe = Pipe()
        task. standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard let output = String(data: data, encoding: .utf8) else { return 0 }
            let lines = output. split(separator: "\n")
            
            for line in lines {
                if line.contains("CPU usage:") {
                    let components = line.split(separator: " ")
                    for (index, component) in components.enumerated() {
                        if component.contains("user") && index > 0 {
                            if let percentage = Double(String(components[index - 1]). replacingOccurrences(of: "%", with: "")) {
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
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>. size/MemoryLayout<integer_t>.size)
        
        let kerr = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                host_statistics64(mach_host_self(),
                                HOST_VM_INFO64,
                                $0,
                                &count)
            }
        }
        
        guard kerr == KERN_SUCCESS else { return (0, 0) }
        
        let usedMemory = Int64(stats.active_count + stats.inactive_count + stats.wire_count) * Int64(vm_kernel_page_size)
        let totalMemory = Int64(ProcessInfo.processInfo.physicalMemory)
        
        return (usedMemory, totalMemory)
    }
    
    private static func getDiskUsage() -> (Int64, Int64)? {
        let task = Process()
        task. launchPath = "/bin/df"
        task.arguments = ["-k", NSHomeDirectory()]
        
        let pipe = Pipe()
        task. standardOutput = pipe
        
        do {
            try task.run()
            let data = pipe. fileHandleForReading.readDataToEndOfFile()
            task.waitUntilExit()
            
            guard let output = String(data: data, encoding: .utf8) else { return nil }
            let lines = output.split(separator: "\n")
            
            if lines.count > 1 {
                let components = lines[1].split(separator: " "). filter { ! $0.isEmpty }
                if components.count >= 3,
                   let total = Int64(components[1]),
                   let available = Int64(components[3]) {
                    let used = total - available
                    return (used * 1024, total * 1024) // Convert to bytes
                }
            }
        } catch {
            print("Error getting disk usage: \(error)")
        }
        
        return nil
    }
    
    private static func getTopProcesses(limit: Int) -> [(name: String, cpu: Double, pid: Int32)] {
        let task = Process()
        task.launchPath = "/usr/bin/top"
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
                
                if ! foundHeader { continue }
                
                let components = line.split(separator: " ", omittingEmptySubsequences: true). map(String.init)
                
                if components.count >= 12,
                   let pid = Int32(components[0]),
                   let cpu = Double(components[2]) {
                    let name = components. last ?? "Unknown"
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
    
    private static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useGB]
        formatter.countStyle = . file
        return formatter.string(fromByteCount: bytes)
    }
}

import Darwin

// Helper for VM statistics
let vm_kernel_page_size: Int = {
    var pagesize: Int = 0
    var len = MemoryLayout<Int>. size
    sysctlbyname("hw.pagesize", &pagesize, &len, nil, 0)
    return pagesize
}()