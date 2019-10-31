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
        if unit == 'seconds':
            unit = 's'
        elif unit == 'minutes':
            unit = 'm'
        elif unit == 'hours':
            unit = 'h'
        elif unit == 'days':
            unit = 'D'
        elif unit == 'weeks':
            unit = 'W'
        elif unit == 'months':
            unit = 'M'
        elif unit == 'years':
            unit = 'Y'

        return number + unit + ' ago'


def subst_author(name):
    return ''.join(map((lambda x: x[0]), name.split(' ')))


def subst_email(email):
    match = split_email.search(email)
    if match == None:
        return email
    else:
        return match[1]


for line in sys.stdin:
    while True:
        match = replace_pattern.search(line)
        if match == None:
            break
        else:
            (beg, end) = match.span()

            command = match[1]
            value = match[2]

            subst = None
            if command == 'age':
                subst = subst_age
            elif command == 'author':
                subst == subst_author
            elif command == 'email':
                subst = subst_email
            
            replacement = ''
            if subst == None:
                replacement = match[0]
            else:
                replacement = subst(value)

            line = line[:beg] + replacement + line[end:]
 
    print(line, end='')

sys.exit(0)
