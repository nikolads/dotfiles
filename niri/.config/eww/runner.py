#!/usr/bin/env python3

import datetime
import json
import os
import re
import selectors
import socket
import subprocess
import time

from niri import NiriState

class State:
    def __init__(self):
        self.niri = NiriState()

def niri_connect():
    addr = os.environ['NIRI_SOCKET']
    print(addr)

    sock = socket.socket(socket.AF_UNIX)
    sock.connect(addr)

    sock.send('"EventStream"\n'.encode('utf-8'))

    msg = sock.recv(8192)
    if json.loads(msg.decode('utf-8')) != {'Ok': 'Handled'}:
        raise Exception("setup niri event stream failed")

    return sock

def niri_callback(state, sock):
    buf = sock.recv(8192).decode('utf-8')
    for line in buf.split('\n'):
        if len(line) == 0:
            continue

        # print(line)
        msg = json.loads(line)
        # print(msg)

        k, v = next(iter(msg.items()))
        state.niri.handle(k, v)

def pactl_connect():
    proc = subprocess.Popen(['pactl', 'subscribe'], stdout=subprocess.PIPE, bufsize=0)
    return proc.stdout

def pactl_callback(state, pa_stream):
    buf = os.read(pa_stream.fileno(), 8192)

    dirty = False
    for line in buf.decode('utf-8').split('\n'):
        # `wpctl` commands generate their own "new/change/remove on client" events.
        # Be careful to not enter an infinite loop.
        if line.startswith("Event 'change' on sink"):
            dirty = True


    if dirty:
        update_volume(state)


def update_volume(state):
    wpctl = subprocess.run(['wpctl', 'get-volume', '@DEFAULT_AUDIO_SINK@'], stdout=subprocess.PIPE)
    wp_out = wpctl.stdout.decode('utf-8')
    wp_out = list(wp_out.split(':'))
    if wp_out[0] == 'Volume':
        vol = wp_out[1].strip()
        vol = int(float(vol) * 100)
        vol = f'{vol}%'

        state.niri.meta['volume'] = vol
        data_meta = json.dumps(state.niri.meta)
        # print(data_meta)
        subprocess.run(['eww', 'update', f'data-meta={data_meta}'])

class Selector:
    def __init__(self):
        self.sel = selectors.DefaultSelector()
        self.timers = []

    def register(self, fd, events, callback):
        self.sel.register(fd, events, callback)

    def unregister(self, fd):
        self.sel.unregister(fd)

    def after(self, duration, callback):
        deadline = time.monotonic() + duration.total_seconds()
        self.timers.append((deadline, callback))

    def run(self):
        while True:
            self.handle_next()

    def handle_next(self):
        now = time.monotonic()
        remaining = None if len(self.timers) == 0 else min(deadline - now for (deadline, _) in self.timers)

        events = self.sel.select(remaining)
        now = time.monotonic()

        for key, _ in events:
            callback = key.data
            callback(key.fileobj)

        if remaining is not None:
            new_timers = []
            for (deadline, callback) in self.timers:
                if deadline < now:
                    callback()
                else:
                    new_timers.append((deadline, callback))

            self.timers = new_timers


def main():
    state = State()

    sel = Selector()

    sock = niri_connect()
    sel.register(sock, selectors.EVENT_READ, lambda fd: niri_callback(state, fd))

    pa_stream = pactl_connect()
    sel.register(pa_stream, selectors.EVENT_READ, lambda fd: pactl_callback(state, fd))

    sel.after(datetime.timedelta(seconds=1), lambda: update_volume(state))

    sel.run()


if __name__ == "__main__":
    try:
        subprocess.run(['eww', 'daemon'])
        subprocess.run(['eww', 'open', 'eww-nsbar'])

        main()
    except KeyboardInterrupt:
        pass
