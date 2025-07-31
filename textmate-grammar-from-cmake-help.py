#!/usr/bin/env python3
import argparse
import re
from os.path import abspath, dirname
from typing import List, Set

from jinja2 import Environment, FileSystemLoader


# function to run a process with arguments and return the output
def run_command(command: List[str]):
    """
    Run a command with arguments and return the output.
    """
    import subprocess
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    if result.returncode != 0:
        raise RuntimeError(f"Command {' '.join(command)} failed with error: {result.stderr}")
    return result.stdout.strip()


def escape_list_for_regex(var_list: List[str]) -> str:
    return "|".join(re.escape(v) for v in sorted(var_list))


class CMakeTextMateGrammarGatherer:
    """
    Class to generate a TextMate grammar for CMake based on the output of CMake's help commands.
    """
    LANGUAGES = ["C", "CXX", "CSharp", "CUDA", "OBJC", "OBJCXX", "Fortran", "HIP", "ISPC", "Swift",
                 "ASM", "ASM_NASM", "ASM_MARMASM", "ASM_MASM", "ASM_ATT"]

    def __init__(self, cmake: str = "cmake"):
        """
        Initialize the gatherer with the path to the CMake executable.
        """
        self.cmake = cmake

    @staticmethod
    def _extract_upper(input_text: str) -> Set[str]:
        """
        Extract all uppercase words from the input text.
        """
        words = set(re.findall(r'\b[A-Z][A-Z_]+\b', input_text))

        # remove unwanted words
        words = {word for word in words if word not in \
                 ("VS", "CXX", "IDE", "NOTFOUND", "NO_", "DFOO", "DBAR", "NEW", "GNU")}

        return set(sorted(words))

    def gather_variables(self):
        """
        Gather CMake variables using the `--help-variable-list` command.
        """
        output = run_command([self.cmake, "--help-variable-list"])

        variables = set()

        for var in [line.strip() for line in output.splitlines() if line.strip()]:
            if "<" in var and ">" in var:
                # Handle language-specific variables
                if "<LANG>" in var:
                    for lang in self.LANGUAGES:
                        variables.add(var.replace("<LANG>", lang))
                # else:
                #     print(f"Skipping variable with angle brackets: {var}")
            else:
                variables.add(var)

        return variables

    @staticmethod
    def control_commands() -> Set[str]:
        """
        Return a set of CMake control commands that do not have arguments.
        """
        return {"break", "continue", "return", "else", "endif", "endwhile", "endforeach", "endmacro",
                "endfunction"}

    def gather_commands(self):
        """
		Gather CMake functions using the `--help-command-list` command.
		"""
        output = run_command([self.cmake, "--help-command-list"])

        commands = set()

        for func in [line.strip() for line in output.splitlines() if line.strip()]:
            commands.add(func)

        # Remove commands which are handled separately
        commands.discard("if")
        commands.discard("elseif")
        commands.discard("while")

        # commands.discard("foreach")

        commands.discard("macro")
        commands.discard("function")

        # Remove commands which have no arguments
        commands -= self.control_commands()

        return sorted(commands)

    def gather_command_keywords(self, function: str):
        """
        Gather argument keywords for a given CMake command using the `--help-command` command.
        """
        output = run_command([self.cmake, "--help-command", function])
        help_text = ' '.join(output.splitlines())

        # extract all signature lines starting with the command name
        signature_pattern = re.compile(rf'\b{function}\b\s*\((.*?)\)', re.DOTALL)
        match = signature_pattern.findall(help_text)
        if not match:
            print(f"No signature found for function: {function}")
            return set()

        # extract keywords from the signatures
        keywords = set()
        for sig in match:
            # replace all multiple spaces with a single space to get a nicer signature
            sig = ' '.join(sig.split())
            keywords |= self._extract_upper(sig)

        # all_kw = self._extract_upper(help_text)
        # if all_kw - keywords:
        #     print(f"possible additional keywords for {function}", all_kw - keywords)

        return sorted(keywords)

    def gather_generator_expressions(self):
        """
        Gather CMake generator expressions using the `--help-manual cmake-generator-expressions` command.
        """
        output = run_command([self.cmake, "--help-manual", "cmake-generator-expressions"])

        help_text = ' '.join(output.splitlines())

        # find all uppercase words after $< up to :
        return sorted(set(re.findall(r'\$<([A-Z_]+):', help_text)))

    def gather_properties(self):
        """
        Gather CMake properties using the `--help-property-list` command.
        """
        output = run_command([self.cmake, "--help-property-list"])

        properties = set()

        for prop in [line.strip() for line in output.splitlines() if line.strip()]:
            if "<" in prop and ">" in prop:
                # Handle language-specific properties
                if "<LANG>" in prop:
                    for lang in self.LANGUAGES:
                        properties.add(prop.replace("<LANG>", lang))
            else:
                properties.add(prop)

        return sorted(properties)

    def version(self):
        """
        Get the CMake version.
        """
        output = run_command([self.cmake, "--version"])
        version_match = re.search(r'cmake version (\d+\.\d+\.\d+)', output)
        if version_match:
            return version_match.group(1)
        else:
            raise RuntimeError("Could not determine CMake version")

    def modules(self) -> Set[str]:
        """
        For the moment this function returns a hardcoded set of CMake modules. Support by
        our gather-function.
        """
        # TODO
        return {"ExternalProject", "FetchContent", "CMakePackageConfigHelpers"}

    def gather_module_functions(self, module: str) -> Set[str]:
        """
        Gather functions from a specific CMake module using the `--help-module` command.
        """
        output = run_command([self.cmake, "--help-module", module])
        help_text = ' '.join(output.splitlines())

        # get all ReST-`.. command::` sections
        command_pattern = re.compile(r'\.\. command::\s+([A-Za-z_]+)', re.DOTALL)
        matches = command_pattern.findall(help_text)

        if not matches:
            raise ValueError(f"No functions found for module: {module}")

        return set(sorted(matches))

    def gather_module_keywords(self, module: str) -> Set[str]:
        """
        Gather keywords for a specific CMake module using the `--help-module` command.
        Get all uppercase words from the help text.
        """
        output = run_command([self.cmake, "--help-module", module])
        help_text = ' '.join(output.splitlines())

        return self._extract_upper(help_text)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate TextMate grammar for CMake.")
    parser.add_argument('--cmake', type=str, default='cmake',
                        help='Path to the CMake executable (default: cmake)')
    parser.add_argument('--output', type=str, default='CMake.tmLanguage.json',
                        help='Output filename for the TextMate grammar (default: CMake.tmLanguage.json)')

    args = parser.parse_args()

    cmake = CMakeTextMateGrammarGatherer(cmake=args.cmake)

    # Set up Jinja environment with this script's directory as the template loader
    script_dir = abspath(dirname(__file__))
    env = Environment(loader=FileSystemLoader(script_dir), trim_blocks=True, lstrip_blocks=True)

    # Expose functions to template
    env.globals['cmake'] = cmake
    env.globals['escape_list_for_regex'] = escape_list_for_regex

    template = env.get_template('CMake.tmLanguage.json.jinja2')
    output = template.render()  # print(f"  Keywords: {', '.join(keywords)}")

    with open(args.output, 'w') as f:
        f.write(output)
