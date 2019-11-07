#!/usr/bin/env python3

import io
import re
import sys

replace_pattern = re.compile('{{{([a-z0-9-_.]*):((}?}?[^}])*)}}}')

split_age = re.compile('^(\d+)\s*([a-z]+)\s*ago$')
split_email = re.compile('^(.*)@.*$')

def subst_age(age):
    match = split_age.search(age)
    if match == None:
        return age
    else:
        number = match.group(1)
        if len(number) < 2:
            number = ' ' + number

        unit = match.group(2)
        unit = (
            's' if unit == 'seconds' else
            'm' if unit == 'minutes' else
            'h' if unit == 'hours' else
            'D' if unit == 'days' else
            'W' if unit == 'weeks' else
            'M' if unit == 'months' else
            'Y' if unit == 'years' else unit
        )

        return number + unit + ' ago'


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

sys.exit(0)
