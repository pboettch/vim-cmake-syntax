set_property(TARGET foo APPEND PROPERTY
INCLUDE_DIRECTORIES ${BAR})

message(STATUS "Hello World")

set_property(TARGET foo APPEND PROPERTY # with comment
INCLUDE_DIRECTORIES ${BAR} "()")

if(VAR)
set_property(TARGET foo APPEND PROPERTY # with comment
INCLUDE_DIRECTORIES ${BAR})

message(STATUS "Hello World")

set_property(TARGET foo APPEND PROPERTY
# with comment
INCLUDE_DIRECTORIES ${BAR})
endif()

if(VAR)
set_property(TARGET
HELLO
HELLO)
endif()

if(VAR)
set_property(
TARGET
HELLO
HELLO)
endif()

message(STATUS "Hello" #[[Bracket Comment]] "second")

add_custom_command() # TODO this will wrongly align to ( due to bracket-comment
