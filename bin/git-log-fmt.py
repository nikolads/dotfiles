#!/usr/bin/env python3

import io
import re
import sys

replace_pattern = re.compile('{{{([a-z0-9-_.]*):((}?}?[^}])*)}}}')

split_ages = re.compile('^((.*)+)\s*ago$')
split_age = re.compile('^\s*(\d+)\s*([a-z]+)\s*')
split_email = re.compile('^(.*)@.*$')

def subst_age(age):
    match = split_ages.search(age)
    if match == None:
        return age
    else:
        ages = match.group(1)

        parts = []
        for age in ages.split(','):
            match = split_age.search(age)
            if match == None:
                parts.append(age)
            else:
                number = match.group(1)

                unit = match.group(2)
                unit = (
                    's' if unit == 'second' or unit == 'seconds' else
                    'm' if unit == 'minute' or unit == 'minutes' else
                    'h' if unit == 'hour' or unit == 'hours' else
                    'D' if unit == 'day' or unit == 'days' else
                    'W' if unit == 'week' or unit == 'weeks' else
                    'M' if unit == 'month' or unit == 'months' else
                    'Y' if unit == 'year' or unit == 'years' else unit
                )

                parts.append(number + unit)

        if len(parts[0]) <= 2:
            parts[0] = ' ' + parts[0]

        return ','.join(parts) + ' ago'


def subst_author(name):
    return ''.join(map((lambda x: x[0]), name.split(' ')))


def subst_email(email):
    match = split_email.search(email)
    return match[1] if match != None else email


for line in sys.stdin:
    while True:
        match = replace_pattern.search(line)
        if match == None:
            break
        else:
            (beg, end) = match.span()

            command = match[1]
            value = match[2]

            subst = (
                subst_age if command == 'age' else
                subst_author if command == 'author' else
                subst_email if command == 'email' else None
            )

            replacement = subst(value) if subst != None else match[0]

            line = line[:beg] + replacement + line[end:]

    print(line, end='')

print('')
sys.exit(0)
