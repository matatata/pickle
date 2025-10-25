if(APPLE)
    cmake_minimum_required(VERSION 3.31)
    set(targetname pickle )

    project(Pickle VERSION 1.0.0)

    # Cmake cannot make universal swift app bundles :-( So I'll do this by hand
    # project(Pickle LANGUAGES Swift)
    # set(CMAKE_OSX_DEPLOYMENT_TARGET 10.14)
    # # Does not work unfortunately:
    # # set(CMAKE_OSX_ARCHITECTURES "arm64;x86_64")

    # add_executable(${targetname} MACOSX_BUNDLE
    #     AppDelegate.swift
    # )            
    # set_target_properties(${targetname} PROPERTIES
    #     BUNDLE True
    #     MACOSX_BUNDLE_GUI_IDENTIFIER my.domain.style.identifier.${targetname}
    #     MACOSX_BUNDLE_BUNDLE_NAME ${targetname}
    #     MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
    #     MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
    #     # MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in
    # )
    # add_custom_command( TARGET ${targetname}
    # POST_BUILD
    # COMMAND codesign -vv --force --options runtime --timestamp --entitlements "${CMAKE_CURRENT_SOURCE_DIR}/pickle.entitlements" --sign "Developer ID Application" "${CMAKE_CURRENT_BINARY_DIR}/${targetname}.app"
    # )


    set(deps "${CMAKE_CURRENT_SOURCE_DIR}/AppDelegate.swift")
    set(app_bundle "${CMAKE_CURRENT_BINARY_DIR}/${targetname}.app")

    set(universal_binary "${app_bundle}/Contents/MacOS/${targetname}")

    file(MAKE_DIRECTORY 
        "${app_bundle}/Contents/MacOS"
    )

    add_custom_command(
        DEPENDS "${deps}"
        OUTPUT ${targetname}_x86_64 ${targetname}_arm64 "${universal_binary}"
        COMMAND rm -f "${universal_binary}"
        COMMAND swiftc ${deps} -o ${targetname}_x86_64 -target x86_64-apple-macos14.0
        COMMAND swiftc ${deps} -o ${targetname}_arm64 -target arm64-apple-macos14.0
        COMMAND lipo -create ${targetname}_x86_64 ${targetname}_arm64 -output "${universal_binary}"
        COMMAND rm ${targetname}_x86_64 ${targetname}_arm64
        COMMAND codesign -vv --force --options runtime --timestamp --entitlements "${CMAKE_CURRENT_SOURCE_DIR}/pickle.entitlements" --sign "Developer ID Application" "${app_bundle}"
    )

    configure_file(Info.plist.in "${app_bundle}/Contents/Info.plist")

    add_custom_target(${targetname} ALL
        DEPENDS ${targetname}_x86_64 ${targetname}_arm64 "${universal_binary}"
    )



   



endif()