#!/usr/bin/python3

import io
import re
import sys

name_pattern = re.compile('{{{author:((}?}?[^}])*)}}}')
age_pattern = re.compile('\((\d+)(\s*[a-z]+)\s*ago\)')

for line in sys.stdin:
    match = name_pattern.search(line)
    if match != None:
        (beg, end) = match.span()

        name = match[1]
        name = ''.join(map((lambda x: x[0]), name.split(' ')))

        line = line[:beg] + name + line[end:]

    match = age_pattern.search(line)
    if match != None:
        (beg, _) = match.span(1)
        (_, end) = match.span(2)

        number = match.group(1)
        if len(number) < 2:
            number = ' ' + number

        unit = match.group(2)
        if unit == ' seconds':
            unit = 's'
        elif unit == ' minutes':
            unit = 'm'
        elif unit == ' hours':
            unit = 'h'
        elif unit == ' days':
            unit = 'd'
        elif unit == ' weeks':
            unit = 'w'
        elif unit == ' months':
            unit = 'M'
        elif unit == ' years':
            unit = 'y'

        line = line[:beg] + number + unit + line[end:]

    print(line, end='')

sys.exit(0)
