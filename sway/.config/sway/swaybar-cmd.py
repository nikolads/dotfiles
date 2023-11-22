#!/usr/bin/env python3

import datetime
import json
import os
import re
import subprocess
import time

def pid_exists(pid):
    try:
        os.kill(pid, 0)
    except ProcessLookupError:
        return False
    except PermissionError:
        return True
    else:
        return True


def get_vol(pactl_lines):
    vol = ''

    vol_mute = filter(lambda line: re.search('^\s*Mute:', line) != None, pactl_lines)
    vol_mute = map(lambda line: re.search('(yes|no)', line), vol_mute)
    vol_mute = filter(lambda match: match != None, vol_mute)
    vol_mute = map(lambda match: match.group(0) == 'yes', vol_mute)
    vol_mute = next(vol_mute, False)

    if vol_mute:
        vol = '-x-'
    else:
        vol_level = filter(lambda line: re.search('^\s*Volume:', line) != None, pactl_lines)
        vol_level = map(lambda line: re.search('[0-9]+%', line), vol_level)
        vol_level = filter(lambda match: match != None, vol_level)
        vol_level = map(lambda match: match.group(0), vol_level)
        vol = next(vol_level, '??')

    return vol


def get_lang(sway_inputs_json):
    inputs = sway_inputs_json
    inputs = map(lambda input: input.get('xkb_active_layout_name', None), inputs)
    inputs = filter(lambda input: input != None, inputs)
    lang_raw = next(iter(inputs), None)

    LANG_MAPPING = {
        'English (US)': 'us',
        'Bulgarian (traditional phonetic)': 'bg'
    }
    return LANG_MAPPING.get(lang_raw, None) or lang_raw


if __name__ == "__main__":
    PPID = os.getppid()

    # Run only if the parent swaybar process is still alive
    #
    # If sway crashes this script will not die and will remain an orphan.
    # Even worse the output gets send to the TTY, so everything becomes a mess.
    # So try to avoid that.
    while pid_exists(PPID):
        date = datetime.datetime.now().strftime('%a, %-d %b %Y %H:%M:%S')

        bat = '??'
        with open('/sys/class/power_supply/BAT0/capacity', 'r') as f:
            bat = f.read().strip()

        pactl = subprocess.run(['pactl', 'list', 'sinks'], stdout=subprocess.PIPE)
        pactl_lines = pactl.stdout.decode('utf-8').split('\n')
        vol = get_vol(pactl_lines)

        sway_inputs = subprocess.run(['swaymsg', '-t', 'get_inputs'], stdout=subprocess.PIPE)
        sway_inputs_json = json.loads(sway_inputs.stdout.decode('utf-8'))
        lang = get_lang(sway_inputs_json)

        print(f'bat {bat}% | vol {vol} | {lang} | {date}', flush=True)
        time.sleep(1)
