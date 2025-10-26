//
//  AppDelegate.swift
//  pickle
//
//  Created by Matteo Ceruti on 25.10.25.
//

import Cocoa
import UniformTypeIdentifiers

//   @main
class AppDelegate: NSObject, NSApplicationDelegate {

    var message:String? = nil;
    var prompt:String? = "Choose";
    var canChooseDirectories = false
    var allowedContentTypes:[UTType] = []
    var allowsMultipleSelection=false
    var treatsFilePackagesAsDirectories = false
    var nonOptArgs:[String] = []
    var print0 = false
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        parse_opts()

        let paths = self.pick()
        if(paths != nil) {
            for path in paths!{
                if(print0) {
                    print("\(path)", terminator: "\0")
                }
                else {
                    print(path)
                }
            }
            
            exit(0)
        }
        
        exit(1)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        //
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    
    func pick() -> [String]? {
        NSApplication.shared.activate()
        let dialog = NSOpenPanel();
        dialog.message = message
        dialog.prompt = prompt
        
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = canChooseDirectories
        dialog.canCreateDirectories    = false
        
        dialog.allowsOtherFileTypes     = false
        dialog.allowedContentTypes      = allowedContentTypes
        dialog.treatsFilePackagesAsDirectories = treatsFilePackagesAsDirectories
        dialog.allowsMultipleSelection = allowsMultipleSelection
        
        guard dialog.runModal() == .OK else { return nil }
        
        return dialog.urls.map { url in
            url.path
        }
    }

    func usage() {
        print("""
    usage:  \(CommandLine.arguments[0]) [-dbftn] [-p <prompt> | -m <message>]
    Options:
        -d              allow to select directories
        -f              allow to select files (includes bundles)
        -t              treat bundles as directories
        -n              allow multiple selection
        -0              print null terminated paths for use with xargs e.g.
        -m <message>    Set message
        -p <prompt>     Set prompt button text
        -h              Print this usage
    """)
    }

    // credits Michele Dall'Agata
    func parse_opts() {
        let pattern = "hnaftbd0m:p:"
        let buffer = Array(pattern.utf8).map { Int8($0) }

        while  true {
            let option = Int(getopt(CommandLine.argc, CommandLine.unsafeArgv, buffer))
            if option == -1 {
                break
            }
            switch "\(UnicodeScalar(option)!)"
            {
            case "h":
                usage()
                exit(0)
            case "0":
                print0 = true
            case "n":
                allowsMultipleSelection = true
            case "d":
                canChooseDirectories = true
                allowedContentTypes.append(.folder)
            case "t":
                treatsFilePackagesAsDirectories = true
            case "f":
                // treatsFilePackagesAsDirectories = true
                allowedContentTypes.append(.item)
            case "p":
                prompt = String(cString: optarg)
            case "m":
                message = String(cString: optarg)
            case "?":
                let charOption = "\(UnicodeScalar(Int(optopt))!)"
                if charOption == "c" {
                    print("Option '\(charOption)' requires an argument.")
                } else {
                    print("Unknown option '\(charOption)' or it requires an argument.")
                }
                exit(1)
            default:
                print("Unknown option \(UnicodeScalar(option)!)")
                print("Try \(CommandLine.arguments[0]) -h")
                exit(1)
            }
        }
       
        for index in optind..<CommandLine.argc {
            nonOptArgs.append("\(CommandLine.arguments[Int(index)])")
        }
    }
    
}

let delegate = AppDelegate()
let app = NSApplication.shared
app.delegate = delegate
app.run()
