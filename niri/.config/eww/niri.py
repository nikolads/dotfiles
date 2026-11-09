import json
import subprocess

from dataclasses import dataclass

@dataclass
class Workspace:
    id: int
    idx: int
    name: str | None
    is_active: bool
    is_urgent: bool
    is_focused: bool

@dataclass
class Window:
    id: int
    workspace_id: int
    app_id: str
    title: str
    is_focused: bool
    layout_pos: list[int]

def kb_layout_map(name):
    if name.startswith('English'):
        return 'us'
    elif name.startswith('Bulgarian'):
        return 'bg'
    else:
        return '??'

class NiriState:
    def __init__(self):
        self.active_workspace_id = None
        self.workspaces = {}
        self.windows = {}
        self.meta = {}
        self.kb_layouts = []


    def handle(self, k, v):
        state = self

        match k:
            case 'WorkspacesChanged':
                workspaces = v['workspaces']
                workspaces = map(lambda ws: Workspace(
                    id=ws['id'],
                    idx=ws['idx'],
                    name=ws['name'],
                    is_active=ws['is_active'],
                    is_urgent=ws['is_urgent'],
                    is_focused=ws['is_focused'],
                ), workspaces)

                state.set_workspaces(workspaces)

                data_ws = json.dumps(state.gen_ws_data())
                subprocess.run(['eww', 'update', f'data-ws={data_ws}'])

            case 'WorkspaceActivated':
                id = v['id']
                focused = v['focused']
                state.set_ws_active(id)

                data_ws = json.dumps(state.gen_ws_data())
                subprocess.run(['eww', 'update', f'data-ws={data_ws}'])

            case 'WindowsChanged':
                windows = v['windows']
                windows = (Window(
                    id = win['id'],
                    workspace_id = win['workspace_id'],
                    app_id = win['app_id'],
                    title = win['title'],
                    is_focused = win['is_focused'],
                    layout_pos = win['layout']['pos_in_scrolling_layout']
                ) for win in windows)

                state.set_windows(windows)

                data_win = json.dumps(state.gen_win_data())
                print(data_win)
                subprocess.run(['eww', 'update', f'data-windows={data_win}'])

            case 'WindowOpenedOrChanged':
                win = v['window']
                win = Window(
                    id = win['id'],
                    workspace_id = win['workspace_id'],
                    app_id = win['app_id'],
                    title = win['title'],
                    is_focused = win['is_focused'],
                    layout_pos = win['layout']['pos_in_scrolling_layout'] or []
                )

                state.windows[win.id] = win

                data_win = json.dumps(state.gen_win_data())
                # print(data_win)
                subprocess.run(['eww', 'update', f'data-windows={data_win}'])

            case 'WindowClosed':
                id = v['id']
                del state.windows[id]

                data_win = json.dumps(state.gen_win_data())
                # print(data_win)
                subprocess.run(['eww', 'update', f'data-windows={data_win}'])

            case 'WorkspaceActiveWindowChanged':
                workspace_id = v['workspace_id']
                active_window_id = v['active_window_id']

                state.set_win_active(active_window_id)

                data_win = json.dumps(state.gen_win_data())
                # print(data_win)
                subprocess.run(['eww', 'update', f'data-windows={data_win}'])

            case 'WindowFocusChanged':
                id = v['id']
                state.set_win_active(id)

                data_win = json.dumps(state.gen_win_data())
                # print(data_win)
                subprocess.run(['eww', 'update', f'data-windows={data_win}'])

            case 'KeyboardLayoutsChanged':
                layouts = v['keyboard_layouts']

                state.kb_layouts = []
                for name in layouts['names']:
                    state.kb_layouts.append(kb_layout_map(name))

                kb_index = layouts['current_idx']
                state.meta['language'] = state.kb_layouts[kb_index]

                data_meta = json.dumps(state.meta)
                subprocess.run(['eww', 'update', f'data-meta={data_meta}'])

            case 'KeyboardLayoutSwitched':
                kb_index = v['idx']
                state.meta['language'] = state.kb_layouts[kb_index]

                data_meta = json.dumps(state.meta)
                subprocess.run(['eww', 'update', f'data-meta={data_meta}'])

            case _:
                # print('unknown key', k)
                pass


    def gen_ws_data(self):
        data = (ws for _, ws in self.workspaces.items())
        data = sorted(data, key=lambda ws: ws.idx)
        data = [{
            'idx': ws.idx,
            'name': ws.name,
            'is_active': ws.is_active,
            'is_urgent': ws.is_urgent,
            'is_focused': ws.is_focused,
        } for ws in data]

        return data

    def gen_win_data(self):
        data = (win for _, win in self.windows.items())
        data = filter(lambda win: win.workspace_id == self.active_workspace_id, data)
        data = sorted(data, key=lambda win: win.layout_pos)
        data = [{
            'app_id': win.app_id,
            'title': win.title,
            'icon_path': f'/usr/share/icons/hicolor/256x256/apps/{win.app_id}.png',
            'is_focused': win.is_focused,
        } for win in data]

        return data

    def set_workspaces(self, workspaces):
        self.workspaces = {}

        for ws in workspaces:
            self.workspaces[ws.id] = ws

            if ws.is_active:
                self.active_workspace_id = ws.id

    def set_ws_active(self, ws_id):
        self.active_workspace_id = None
        for _, ws in self.workspaces.items():
            ws.is_active = False

        ws = self.workspaces.get(ws_id, None)
        if ws is not None:
            self.active_workspace_id = ws_id
            ws.is_active = True

    def set_windows(self, windows):
        self.windows = {}

        for win in windows:
            self.windows[win.id] = win

    def set_win_active(self, win_id):
        for _, win in self.windows.items():
            win.is_focused = False

        win = self.windows.get(win_id, None)
        if win is not None:
            win.is_focused = True

