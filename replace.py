#!/user/bin/python3
'''
File: replace.py

Description: This script will replace the specified keys with the 
    given values.

    Example:
        > python3 replace.py myfile.txt SOME_TOKEN=hello SOME_OTHER_TOKEN=world

    Known limitations: 
        If any of the values contains any of the tokens, the behaviour 
        is not defined

Usage: 
    python3 replace.py <file> <TOKEN>=<value> [<TOKEN2>=<value2> ...]

    This programm has two required arguments:
        <file>:
            A path to the file in which values will be replaced.

        <TOKEN>=<value>:
            There can be as many of these token=value pairs as needed.
            E.g. PATH_TO_SOME_FILE=/real/path/to/file

            If the value contains spaces, it should be enclosed in 
            double quotes. 
            E.g. SOME_TOKEN="some value with spaces"

Author: miggoncan 

Date: 28-june-2020
'''
import sys
import os

# Temporary file used to write the replaced tokens
TEMP_FILE = 'tempFile.txt'


def main():
    file = sys.argv[1]

    # Transform the arguments into a dict
    data = {}
    for val in sys.argv[2:]:
        separatorIndex = val.find('=')
        key, value = val[:separatorIndex], val[separatorIndex+1:]
        data[key] = value
    
    # Use a temporary file to write the modified content
    with open(file, 'r') as src:
        with open(TEMP_FILE, 'w') as dest:
            for line in src:
                for key, value in data.items():
                    if value.startswith('"') and value.endswith('"'):
                        value = value[1:len(value)-1]
                    line = line.replace(key, value)
                dest.write(line)
    os.rename(TEMP_FILE, file)


if __name__ == '__main__':
    if len(sys.argv) <= 2:
        print(f'Usage: ${sys.argv[0]} <file> <TOKEN>=<value> [<TOKEN2>=<value2> ...]')
        sys.exit(1)
    main()