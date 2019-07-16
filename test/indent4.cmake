set_property(TARGET foo APPEND PROPERTY
# with comment
    INCLUDE_DIRECTORIES ${BAR})

message(STATUS "Hello World")

# expected
#set_property(TARGET foo APPEND PROPERTY
#             # with comment
#             INCLUDE_DIRECTORIES ${BAR})
#
#message(STATUS "Hello World")
