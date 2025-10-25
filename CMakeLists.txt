if(APPLE)
    cmake_minimum_required(VERSION 3.31)
    set(targetname pickle )

    project(Pickle VERSION 1.0.0)

    file(GLOB deps "${CMAKE_CURRENT_SOURCE_DIR}/*.swift")
    set(XIBS ConfirmPathsView)

    set(app_bundle "${CMAKE_CURRENT_BINARY_DIR}/${targetname}.app")

    set(universal_binary "${app_bundle}/Contents/MacOS/${targetname}")

    file(MAKE_DIRECTORY 
        "${app_bundle}/Contents/MacOS"
        "${app_bundle}/Contents/Resources"
    )

    add_custom_target(${targetname} ALL
        DEPENDS ${targetname}_x86_64 ${targetname}_arm64 "${universal_binary}"
    )

    find_program(IBTOOL ibtool REQUIRED)
    foreach(XIBFILE ${XIBS})
        add_custom_command(
                TARGET ${targetname}
                POST_BUILD
                COMMAND ${IBTOOL} --compile "${app_bundle}/Contents/Resources/${XIBFILE}.nib" "${CMAKE_CURRENT_SOURCE_DIR}/${XIBFILE}.xib"
                COMMENT "Compiling NIB file ${XIBFILE}.nib")
    endforeach()


    file(COPY ${nibs} DESTINATION "${app_bundle}/Contents/Resources")

    add_custom_command(
        DEPENDS "${deps}"
        OUTPUT ${targetname}_x86_64 ${targetname}_arm64 "${universal_binary}"
        COMMAND rm -f "${universal_binary}"
        COMMAND swiftc -O ${deps} -o ${targetname}_x86_64 -target x86_64-apple-macos14.0
        COMMAND swiftc -O ${deps} -o ${targetname}_arm64 -target arm64-apple-macos14.0
        COMMAND lipo -create ${targetname}_x86_64 ${targetname}_arm64 -output "${universal_binary}"
        COMMAND rm ${targetname}_x86_64 ${targetname}_arm64
        COMMAND codesign -vv --force --options runtime  --timestamp --sign "Developer ID Application" "${app_bundle}"
    )

    configure_file(Info.plist.in "${app_bundle}/Contents/Info.plist")

    



   



endif()